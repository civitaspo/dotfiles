return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        win = {
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
