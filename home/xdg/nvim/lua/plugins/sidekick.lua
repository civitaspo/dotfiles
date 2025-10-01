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
            prompt = { "<c-.>", "prompt" },
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
