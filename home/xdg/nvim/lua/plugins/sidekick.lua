return {
  {
    "folke/sidekick.nvim",
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
