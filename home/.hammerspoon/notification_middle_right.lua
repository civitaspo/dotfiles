-- Move macOS notification banners to the middle-right of the menubar
-- display. Do not run this together with ShoveIt / PingPlace.
--
-- Tune vertical placement with Y_NUDGE (larger = up, negative = down),
-- then Reload Config. If dump() shows kind=other, add that Mac's
-- AXSubrole to bannerSubroles.

local obj = {}

-- Larger values move banners up; negative values move them down.
obj.Y_NUDGE = 0

obj.bannerSubroles = {
  "AXNotificationCenterBanner",
  "AXNotificationCenterAlert",
  "AXNotificationCenterNotification",
  "AXNotificationCenterBannerWindow",
  -- macOS 26: stacked banners become one container with this subrole.
  "AXNotificationCenterAlertStack",
}

local NC_BUNDLE_ID = "com.apple.notificationcenterui"
local WIDGET_EDITOR_ID = "widget-editor-button"
local WIDGET_ID_PREFIX = "widget-local:"
local MAX_NODES = 10000
local RIGHT_PADDING = 16
local POLL_SECONDS = 0.2
local MOVE_EPSILON = 1

local function axGet(el, name)
  if not el then
    return nil
  end
  local ok, value = pcall(function()
    return el:attributeValue(name)
  end)
  if ok then
    return value
  end
  return nil
end

local function axSettable(el, name)
  if not el then
    return false
  end
  local ok, value = pcall(function()
    return el:isAttributeSettable(name)
  end)
  return ok and value == true
end

local function axSet(el, name, value)
  if not el then
    return false
  end
  local ok, result = pcall(function()
    return el:setAttributeValue(name, value)
  end)
  return ok and result ~= nil
end

local function axChildren(el)
  local seen = {}
  local out = {}
  for _, key in ipairs({ "AXChildren", "AXOrderedChildren" }) do
    local children = axGet(el, key) or {}
    for _, child in ipairs(children) do
      if child and not seen[child] then
        seen[child] = true
        table.insert(out, child)
      end
    end
  end
  return out
end

local function bannerSubroleSet()
  local set = {}
  for _, name in ipairs(obj.bannerSubroles) do
    set[name] = true
  end
  return set
end

local function notificationCenterApp()
  local apps = hs.application.applicationsForBundleID(NC_BUNDLE_ID)
  if apps and apps[1] then
    return apps[1]
  end
  return nil
end

local function menubarScreen()
  return hs.screen.primaryScreen()
end

local function formatPoint(point)
  if type(point) ~= "table" then
    return "nil"
  end
  return string.format("{x=%.1f, y=%.1f}", point.x or 0, point.y or 0)
end

local function formatSize(size)
  if type(size) ~= "table" then
    return "nil"
  end
  return string.format("{w=%.1f, h=%.1f}", size.w or 0, size.h or 0)
end

local function classifyWindow(window)
  local pending = { window }
  local visited = {}
  local n = 0
  local banner = nil
  local hasWidget = false

  local bannerSet = bannerSubroleSet()

  while #pending > 0 do
    local el = table.remove(pending)
    if el and not visited[el] then
      visited[el] = true
      n = n + 1
      if n > MAX_NODES then
        return "other", nil
      end

      local identifier = axGet(el, "AXIdentifier")
      if identifier == WIDGET_EDITOR_ID then
        return "panel", nil
      end
      if type(identifier) == "string" and identifier:sub(1, #WIDGET_ID_PREFIX) == WIDGET_ID_PREFIX then
        hasWidget = true
      end

      local subrole = axGet(el, "AXSubrole")
      if not banner and type(subrole) == "string" and bannerSet[subrole] then
        banner = el
      end

      for _, child in ipairs(axChildren(el)) do
        table.insert(pending, child)
      end
    end
  end

  if hasWidget then
    return "widget", nil
  end
  if banner then
    return "banner", banner
  end
  return "other", nil
end

local function targetForBanner(size)
  local frame = menubarScreen():fullFrame()
  return {
    x = frame.x + frame.w - size.w - RIGHT_PADDING,
    y = frame.y + (frame.h - size.h) / 2 - obj.Y_NUDGE,
  }
end

local function farFrom(a, b)
  if type(a) ~= "table" or type(b) ~= "table" then
    return true
  end
  return math.abs((a.x or 0) - (b.x or 0)) > MOVE_EPSILON
    or math.abs((a.y or 0) - (b.y or 0)) > MOVE_EPSILON
end

local function moveBanner(window, banner)
  local bannerPos = axGet(banner, "AXPosition")
  local bannerSize = axGet(banner, "AXSize")
  if type(bannerPos) ~= "table" or type(bannerSize) ~= "table" then
    return
  end

  local target = targetForBanner(bannerSize)

  if axSettable(banner, "AXPosition") then
    if farFrom(bannerPos, target) then
      axSet(banner, "AXPosition", target)
    end
    return
  end

  if not axSettable(window, "AXPosition") then
    return
  end

  local windowPos = axGet(window, "AXPosition")
  if type(windowPos) ~= "table" then
    return
  end

  local windowTarget = {
    x = target.x - (bannerPos.x - windowPos.x),
    y = target.y - (bannerPos.y - windowPos.y),
  }
  if farFrom(windowPos, windowTarget) then
    axSet(window, "AXPosition", windowTarget)
  end
end

local function eachWindow(fn)
  local app = notificationCenterApp()
  if not app then
    return
  end
  local axApp = hs.axuielement.applicationElement(app)
  if not axApp then
    return
  end
  for _, window in ipairs(axGet(axApp, "AXWindows") or {}) do
    fn(window)
  end
end

local function reposition()
  eachWindow(function(window)
    local kind, banner = classifyWindow(window)
    if kind == "banner" and banner then
      moveBanner(window, banner)
    end
  end)
end

local function describe(el)
  local subrole = axGet(el, "AXSubrole")
  local kind = "other"
  if type(subrole) == "string" and bannerSubroleSet()[subrole] then
    kind = "banner"
  end
  return string.format(
    "kind=%s settable=%s role=%s subrole=%s id=%s AXPosition=%s AXSize=%s",
    kind,
    tostring(axSettable(el, "AXPosition")),
    tostring(axGet(el, "AXRole")),
    tostring(subrole),
    tostring(axGet(el, "AXIdentifier")),
    formatPoint(axGet(el, "AXPosition")),
    formatSize(axGet(el, "AXSize"))
  )
end

function obj:dump()
  local app = notificationCenterApp()
  if not app then
    print("notification_middle_right: dump: Notification Center is not running")
    return self
  end
  if not hs.accessibilityState() then
    print("notification_middle_right: dump: Hammerspoon is not trusted for Accessibility")
  end

  local count = 0
  eachWindow(function(window)
    count = count + 1
    local windowKind = classifyWindow(window)
    print(string.format(
      "notification_middle_right: window#%d windowKind=%s %s",
      count,
      windowKind,
      describe(window)
    ))

    local pending = axChildren(window)
    local n = 0
    while #pending > 0 do
      local el = table.remove(pending, 1)
      n = n + 1
      if n > MAX_NODES then
        break
      end
      local subrole = axGet(el, "AXSubrole")
      local identifier = axGet(el, "AXIdentifier")
      if subrole or identifier or axSettable(el, "AXPosition") then
        print("notification_middle_right:   " .. describe(el))
      end
      for _, child in ipairs(axChildren(el)) do
        table.insert(pending, child)
      end
    end
  end)

  if count == 0 then
    print("notification_middle_right: dump: no AXWindows (send a test banner first)")
  end
  return self
end

local function watchNotifications()
  local notifications = hs.axuielement.observer.notifications
  return {
    notifications and notifications.windowCreated,
    notifications and notifications.created,
    notifications and notifications.layoutChanged,
    notifications and notifications.uIElementDestroyed,
    "AXChildrenChanged",
  }
end

local function attachObserver()
  if obj._observer then
    pcall(function()
      obj._observer:stop()
    end)
    obj._observer = nil
  end

  local app = notificationCenterApp()
  if not app then
    return
  end

  local axApp = hs.axuielement.applicationElement(app)
  if not axApp then
    return
  end

  local observer = hs.axuielement.observer.new(app:pid())
  observer:callback(function()
    reposition()
  end)
  for _, notification in ipairs(watchNotifications()) do
    if notification then
      pcall(function()
        observer:addWatcher(axApp, notification)
      end)
      for _, window in ipairs(axGet(axApp, "AXWindows") or {}) do
        pcall(function()
          observer:addWatcher(window, notification)
        end)
      end
    end
  end
  observer:start()
  obj._observer = observer
end

function obj:start()
  if obj._running then
    return self
  end
  obj._running = true

  if not hs.accessibilityState() then
    print("notification_middle_right: Hammerspoon needs Accessibility permission")
  end

  attachObserver()
  obj._timer = hs.timer.doEvery(POLL_SECONDS, function()
    if not obj._observer and notificationCenterApp() then
      attachObserver()
    end
    reposition()
  end)
  reposition()
  print("notification_middle_right: started")
  return self
end

function obj:stop()
  if obj._timer then
    obj._timer:stop()
    obj._timer = nil
  end
  if obj._observer then
    pcall(function()
      obj._observer:stop()
    end)
    obj._observer = nil
  end
  obj._running = false
  print("notification_middle_right: stopped")
  return self
end

return obj
