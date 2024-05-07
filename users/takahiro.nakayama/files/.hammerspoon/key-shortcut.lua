do
  local function activateApp(name)
    if not hs.application.launchOrFocus(name) and not hs.application.launchOrFocusByBundleID(name) then
      hs.alert(name .. " could not be launched or focused.", 0.5)
    end
  end

  hs.hotkey.bind({ "cmd" }, "1", function()
    activateApp("1Password")
  end)
  hs.hotkey.bind({ "cmd" }, "2", function()
    activateApp("Alacritty")
  end)
  hs.hotkey.bind({ "cmd" }, "3", function()
    activateApp("Arc")
  end)
  hs.hotkey.bind({ "cmd" }, "4", function()
    activateApp("Slack")
  end)
  hs.hotkey.bind({ "cmd" }, "5", function()
    activateApp("Notes")
  end)
  hs.hotkey.bind({ "cmd" }, "6", function()
    activateApp("Gather")
  end)
  hs.hotkey.bind({ "cmd" }, "8", function()
    activateApp("Notion Calendar")
  end)
  hs.hotkey.bind({ "cmd" }, "9", function()
    activateApp("Things3")
  end)
  hs.hotkey.bind({ "cmd" }, "0", function()
    activateApp("Mimestream")
  end)
end

