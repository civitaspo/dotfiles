-- NOTE: This parent is defined in `./refactoring.lua`
-- require("which-key").register({
--   mode = { "n", "x" },
--   ["<leader>r"] = { name = "+refactoring" },
-- })

return {
  {
    "Wansmer/treesj",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- https://github.com/Wansmer/treesj
      use_default_keymaps = false,
    },
    keys = {
      {
        "<leader>rt",
        mode = {"n"},
        function() require('treesj').toggle() end,
        desc = "Split/Join",
      },
    },
  }
}
