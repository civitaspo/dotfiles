package.path = os.getenv("HOME") .. "/src/github.com/civitaspo/rex-agent-relay/?/init.lua;" .. package.path
require("rex-agent-relay").setup({ key = "cmd+enter" })
