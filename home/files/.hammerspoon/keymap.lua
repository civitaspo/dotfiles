do
  local function isActiveApp(appName)
    return hs.application.frontmostApplication():name() == appName
  end
  local function appKeyBinding(appName, modifiers, key, fn)
    if isActiveApp(appName) then
      hs.hotkey.bind(modifiers, key, fn)
    else
      hs.hotkey.disableAll(modifiers, key)
    end
  end
  local function emacsKeyBindings(appName)
    appKeyBinding(appName, { "ctrl" }, "f", function()
      hs.eventtap.keyStroke({}, "right")
    end)
    appKeyBinding(appName, { "ctrl" }, "b", function()
      hs.eventtap.keyStroke({}, "left")
    end)
    appKeyBinding(appName, { "ctrl" }, "n", function()
      hs.eventtap.keyStroke({}, "down")
    end)
    appKeyBinding(appName, { "ctrl" }, "p", function()
      hs.eventtap.keyStroke({}, "up")
    end)
    appKeyBinding(appName, { "ctrl" }, "a", function()
      hs.eventtap.keyStroke({}, "home")
    end)
    appKeyBinding(appName, { "ctrl" }, "e", function()
      hs.eventtap.keyStroke({}, "end")
    end)
    appKeyBinding(appName, { "ctrl" }, "d", function()
      hs.eventtap.keyStroke({}, "forwarddelete")
    end)
    appKeyBinding(appName, { "ctrl" }, "h", function()
      hs.eventtap.keyStroke({}, "delete")
    end)
    appKeyBinding(appName, { "ctrl" }, "k", function()
      hs.eventtap.keyStroke({}, "shift-end", "delete")
    end)
  end
  local function keyBindings()
    emacsKeyBindings("Mimestream")
    emacsKeyBindings("Arc")
    emacsKeyBindings("Heptabase")
    emacsKeyBindings("Slack")
    emacsKeyBindings("Things3")
  end
  local appWatcher = hs.application.watcher.new(function(name, event, app)
    if event == hs.application.watcher.activated then
      keyBindings()
    end
  end)
  appWatcher:start()
end
