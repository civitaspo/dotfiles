return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        win = {
          layout = "right",
          split = {
            width = 105, -- 90~110 is good for me.
          },
          keys = {
            buffers = { "<c-b>", "buffers", mode = "n", desc = "open buffer picker" },
            files = { "<c-f>", "files", mode = "n", desc = "open file picker" },
            prompt = { "<c-.>", "prompt" },
            nav_left = { "<c-,>", "nav_left", expr = true, desc = "navigate to the left window" },
            nav_down = nil,
            nav_up = { "<c-,>", "nav_up", expr = true, desc = "navigate to the above window" },
            nav_right = nil,
          },
        },
      },
    },
    keys = {
      {
        "<c-,>",
        function()
          require("sidekick.cli").toggle({ focus = true })
        end,
        desc = "Sidekick Toggle CLI",
        mode = { "n", "v" },
      },
    },
  },
}
