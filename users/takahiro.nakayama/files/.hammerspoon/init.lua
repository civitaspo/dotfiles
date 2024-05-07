do
  local function reloadConfig(files)
    doReload = false
    for _, file in pairs(files) do
      if file:sub(-4) == ".lua" then
        doReload = true
        print("-- Loading config: " .. file)
      end
    end
    if doReload then
      hs.reload()
    end
  end
  -- Use Global Variables for preventing GC
  pathWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
  pathWatcher:start()
end

require("keymap")
require("key-shortcut")
