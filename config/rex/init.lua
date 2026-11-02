package.path = os.getenv("HOME") .. "/src/github.com/civitaspo/rex-agent-relay/?/init.lua;" .. package.path
require("rex-agent-relay").setup({ key = "cmd+enter" })

rex.bind("ctrl+t>ctrl+t", "pane.split", { direction = "right" })
rex.bind("ctrl+t>ctrl+p", "client.tab.previous")
rex.bind("ctrl+t>ctrl+n", "client.tab.next")
rex.bind("ctrl+t>ctrl+b", "pane.focus_previous")
rex.bind("ctrl+t>ctrl+f", "pane.focus_next")

rex.bind("cmd+up", "client.tab.previous")
rex.bind("cmd+down", "client.tab.next")
rex.bind("cmd+left", "pane.focus_previous")
rex.bind("cmd+right", "pane.focus_next")
