-- Notification Center banners: middle-right native placement, optional
-- notch-style island overlay, and timed dismiss for passive banners.
-- Do not run this together with ShoveIt / PingPlace.
--
-- STYLE = "island" draws a custom pill at the top-center of the menubar
-- display and hides the system banner. STYLE = "native" keeps the system
-- chrome and only nudges it to middle-right.
--
-- macOS does not let us restyle the system banner itself.
--
-- DISMISS_AFTER applies only when the banner has no extra actions
-- (Reply / Snooze / Approve, etc.). Set to 0 to disable.
--
-- Tune native vertical placement with Y_NUDGE (larger = up). If dump()
-- shows kind=other, add that Mac's AXSubrole to bannerSubroles.

local obj = {}

obj.Y_NUDGE = 0
obj.STYLE = "island"
obj.DISMISS_AFTER = 8

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
local HIDDEN_ORIGIN = { x = -4000, y = -4000 }
local ISLAND_MAX_WIDTH = 420
local ISLAND_MIN_WIDTH = 160
local ISLAND_PAD_X = 18
local ISLAND_TOP = 6
local ISLAND_STACK_GAP = 8
local CLOSE_RETRY_SECONDS = 1

local CLOSE_LABELS = {
  close = true,
  dismiss = true,
  ["clear all"] = true,
  ["閉じる"] = true,
  ["すべてクリア"] = true,
  ["クリア"] = true,
}

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

local function axActionNames(el)
  if not el then
    return {}
  end
  local ok, names = pcall(function()
    return el:actionNames()
  end)
  if ok and type(names) == "table" then
    return names
  end
  return {}
end

local function axActionDescription(el, name)
  local ok, desc = pcall(function()
    return el:actionDescription(name)
  end)
  if ok and type(desc) == "string" then
    return desc
  end
  return ""
end

local function axPerform(el, name)
  if not el or not name then
    return false
  end
  local ok, result = pcall(function()
    return el:performAction(name)
  end)
  return ok and result ~= false and result ~= nil
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

local function normalizeLabel(text)
  if type(text) ~= "string" then
    return ""
  end
  text = text:gsub("^%s+", ""):gsub("%s+$", "")
  return string.lower(text)
end

local function isCloseLabel(text)
  local label = normalizeLabel(text)
  return label ~= "" and CLOSE_LABELS[label] == true
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

local function inspectBanner(banner)
  local texts = {}
  local needsAction = false
  local closeAction = nil
  local n = 0
  local pending = { banner }
  local visited = {}

  while #pending > 0 do
    local el = table.remove(pending)
    if el and not visited[el] then
      visited[el] = true
      n = n + 1
      if n > MAX_NODES then
        break
      end

      local role = axGet(el, "AXRole")
      if role == "AXStaticText" or role == "AXHeading" then
        local value = axGet(el, "AXValue") or axGet(el, "AXTitle")
        if type(value) == "string" and value ~= "" then
          table.insert(texts, value)
        end
      elseif role == "AXTextField" or role == "AXTextArea" then
        needsAction = true
      elseif role == "AXButton" or role == "AXMenuButton" then
        local title = axGet(el, "AXTitle") or axGet(el, "AXDescription") or axGet(el, "AXHelp") or ""
        if title ~= "" and not isCloseLabel(title) then
          needsAction = true
        end
      end

      for _, name in ipairs(axActionNames(el)) do
        local desc = axActionDescription(el, name)
        if isCloseLabel(desc) or isCloseLabel(name) then
          if not closeAction then
            closeAction = { el = el, name = name }
          end
        end
      end

      for _, child in ipairs(axChildren(el)) do
        table.insert(pending, child)
      end
    end
  end

  return texts, needsAction, closeAction
end

local function bannerId(banner, texts)
  local identifier = axGet(banner, "AXIdentifier")
  if type(identifier) == "string" and identifier ~= "" then
    return identifier
  end
  if #texts > 0 then
    return table.concat(texts, "\n")
  end
  return tostring(banner)
end

local function targetForNative(size)
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

local function moveTo(window, banner, target)
  local bannerPos = axGet(banner, "AXPosition")
  local bannerSize = axGet(banner, "AXSize")
  if type(bannerPos) ~= "table" or type(bannerSize) ~= "table" then
    return
  end

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

local function closeBanner(banner, closeAction)
  if closeAction and axPerform(closeAction.el, closeAction.name) then
    return true
  end

  local pending = { banner }
  local visited = {}
  local n = 0
  while #pending > 0 do
    local el = table.remove(pending)
    if el and not visited[el] then
      visited[el] = true
      n = n + 1
      if n > MAX_NODES then
        break
      end
      local role = axGet(el, "AXRole")
      if role == "AXButton" then
        local title = axGet(el, "AXTitle") or axGet(el, "AXDescription") or ""
        if isCloseLabel(title) and axPerform(el, "AXPress") then
          return true
        end
      end
      for _, name in ipairs(axActionNames(el)) do
        if isCloseLabel(axActionDescription(el, name)) and axPerform(el, name) then
          return true
        end
      end
      for _, child in ipairs(axChildren(el)) do
        table.insert(pending, child)
      end
    end
  end
  return false
end

local function activateBanner(banner)
  if axPerform(banner, "AXPress") then
    return true
  end
  local window = axGet(banner, "AXWindow") or banner
  return axPerform(window, "AXRaise")
end

local function ellipsize(text, maxChars)
  if type(text) ~= "string" or text == "" then
    return ""
  end
  local len = utf8.len(text)
  if not len or len <= maxChars then
    return text
  end
  return text:sub(1, utf8.offset(text, maxChars + 1) - 1) .. "…"
end

local function islandCopy(texts)
  local title = texts[1] or ""
  local body = texts[2] or ""
  if texts[1] and texts[2] and texts[3] then
    title = texts[2]
    body = texts[3]
  elseif #texts == 1 then
    body = ""
  end
  title = ellipsize(title, 36)
  body = ellipsize(body, 48)
  if body == title then
    body = ""
  end
  return title, body
end

local function estimatedTextWidth(text, textSize)
  local len = utf8.len(text) or #text
  return len * textSize * 0.62
end

local function hideIsland(id)
  local canvas = obj._islands and obj._islands[id]
  if canvas then
    pcall(function()
      canvas:hide()
      canvas:delete()
    end)
    obj._islands[id] = nil
  end
end

local function hideAllIslands()
  if not obj._islands then
    return
  end
  for id in pairs(obj._islands) do
    hideIsland(id)
  end
end

local function showIsland(id, title, body, banner, index)
  if title == "" and body == "" then
    title = "Notification"
  end

  local textWidth = math.max(
    estimatedTextWidth(title, 13),
    body ~= "" and estimatedTextWidth(body, 12) or 0
  )
  local width = math.max(ISLAND_MIN_WIDTH, math.min(ISLAND_MAX_WIDTH, textWidth + ISLAND_PAD_X * 2))
  local height = body ~= "" and 54 or 36
  local screen = menubarScreen():fullFrame()
  local frame = {
    x = screen.x + (screen.w - width) / 2,
    y = screen.y + ISLAND_TOP + (index - 1) * (height + ISLAND_STACK_GAP),
    w = width,
    h = height,
  }

  hideIsland(id)
  local canvas = hs.canvas.new(frame)
  local radius = height / 2
  canvas[1] = {
    id = "bg",
    type = "rectangle",
    action = "fill",
    roundedRectRadii = { xRadius = radius, yRadius = radius },
    fillColor = { hex = "#0B0B0D", alpha = 0.94 },
    trackMouseUp = true,
    frame = { x = 0, y = 0, w = "100%", h = "100%" },
  }
  canvas[2] = {
    id = "title",
    type = "text",
    text = title,
    textSize = 13,
    textFont = ".AppleSystemUIFont",
    textColor = { hex = "#FFFFFF", alpha = 0.96 },
    textAlignment = "center",
    frame = {
      x = ISLAND_PAD_X,
      y = body ~= "" and 8 or 9,
      w = width - ISLAND_PAD_X * 2,
      h = 18,
    },
  }
  if body ~= "" then
    canvas[3] = {
      id = "body",
      type = "text",
      text = body,
      textSize = 12,
      textFont = ".AppleSystemUIFont",
      textColor = { hex = "#EBEBF5", alpha = 0.62 },
      textAlignment = "center",
      frame = {
        x = ISLAND_PAD_X,
        y = 28,
        w = width - ISLAND_PAD_X * 2,
        h = 16,
      },
    }
  end

  canvas:level(hs.canvas.windowLevels.overlay)
  pcall(function()
    canvas:behaviorAsLabels({ "canJoinAllSpaces", "stationary" })
  end)
  canvas:clickActivating(false)
  canvas:mouseCallback(function(_, message)
    if message == "mouseUp" then
      activateBanner(banner)
    end
  end)
  canvas:show()
  obj._islands[id] = canvas
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

local function tick()
  obj._seen = obj._seen or {}
  obj._islands = obj._islands or {}

  local present = {}
  local islands = {}
  local now = hs.timer.secondsSinceEpoch()
  local useIsland = obj.STYLE == "island"

  eachWindow(function(window)
    local kind, banner = classifyWindow(window)
    if kind ~= "banner" or not banner then
      return
    end

    local texts, needsAction, closeAction = inspectBanner(banner)
    local id = bannerId(banner, texts)
    present[id] = true

    local entry = obj._seen[id]
    if not entry then
      entry = { firstSeen = now }
      obj._seen[id] = entry
    end
    entry.banner = banner
    entry.window = window
    entry.needsAction = needsAction
    entry.closeAction = closeAction
    entry.texts = texts

    local dismissAfter = tonumber(obj.DISMISS_AFTER) or 0
    if dismissAfter > 0 and not needsAction and (now - entry.firstSeen) >= dismissAfter then
      if not entry.closeTriedAt or (now - entry.closeTriedAt) >= CLOSE_RETRY_SECONDS then
        entry.closeTriedAt = now
        if closeBanner(banner, closeAction) then
          entry.closed = true
          hideIsland(id)
        end
      end
    end

    local bannerSize = axGet(banner, "AXSize")
    if useIsland and not entry.closed then
      moveTo(window, banner, HIDDEN_ORIGIN)
      table.insert(islands, {
        id = id,
        banner = banner,
        firstSeen = entry.firstSeen,
      })
    elseif not useIsland and type(bannerSize) == "table" then
      moveTo(window, banner, targetForNative(bannerSize))
    end
  end)

  if useIsland then
    table.sort(islands, function(a, b)
      return a.firstSeen < b.firstSeen
    end)
    for index, item in ipairs(islands) do
      local entry = obj._seen[item.id]
      local title, body = islandCopy(entry.texts)
      local sig = table.concat({ item.id, title, body, tostring(index) }, "\0")
      if entry.islandSig ~= sig then
        showIsland(item.id, title, body, item.banner, index)
        entry.islandSig = sig
      end
    end
  else
    hideAllIslands()
  end

  for id in pairs(obj._seen) do
    if not present[id] then
      hideIsland(id)
      obj._seen[id] = nil
    end
  end
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
  print(string.format(
    "notification_middle_right: dump STYLE=%s DISMISS_AFTER=%s Y_NUDGE=%s",
    tostring(obj.STYLE),
    tostring(obj.DISMISS_AFTER),
    tostring(obj.Y_NUDGE)
  ))

  local count = 0
  eachWindow(function(window)
    count = count + 1
    local windowKind, banner = classifyWindow(window)
    local extra = ""
    if banner then
      local texts, needsAction = inspectBanner(banner)
      extra = string.format(
        " needsAction=%s texts=%s",
        tostring(needsAction),
        hs.inspect(texts)
      )
    end
    print(string.format(
      "notification_middle_right: window#%d windowKind=%s %s%s",
      count,
      windowKind,
      describe(window),
      extra
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
    tick()
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
  obj._seen = {}
  obj._islands = {}

  if not hs.accessibilityState() then
    print("notification_middle_right: Hammerspoon needs Accessibility permission")
  end

  attachObserver()
  obj._timer = hs.timer.doEvery(POLL_SECONDS, function()
    if not obj._observer and notificationCenterApp() then
      attachObserver()
    end
    tick()
  end)
  tick()
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
  hideAllIslands()
  obj._seen = {}
  obj._running = false
  print("notification_middle_right: stopped")
  return self
end

return obj
