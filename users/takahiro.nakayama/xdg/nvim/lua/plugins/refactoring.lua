require("which-key").register({
  mode = { "n", "x" },
  ["<leader>r"] = { name = "+refactoring" },
})

return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- https://github.com/ThePrimeagen/refactoring.nvim/blob/d2786877c91aa409c824f27b4ce8a9f560dda60a/lua/refactoring/config/init.lua
      prompt_func_return_type = {
        go = true,
        java = true,
      },
      prompt_func_param_type = {
        go = true,
        java = true,
      },
      printf_statements = {},
      print_var_statements = {},
      show_success_message = false,
    },
    keys = {
      -- https://github.com/ThePrimeagen/refactoring.nvim/tree/master?tab=readme-ov-file#lua-api-
      {
        "<leader>re",
        mode = {"x"},
        function() require('refactoring').refactor('Extract Function') end,
        desc = "Extract Function",
      },
      {
        "<leader>rf",
        mode = {"x"},
        function() require('refactoring').refactor('Extract Function To File') end,
        desc = "Extract Function To File",
      },
      {
        "<leader>rv",
        mode = {"x"},
        function() require('refactoring').refactor('Extract Variable') end,
        desc = "Extract Variable",
      },
      {
        "<leader>rI",
        mode = {"n"},
        function() require('refactoring').refactor('Inline Function') end,
        desc = "Inline Function",
      },
      {
        "<leader>ri",
        mode = {"n", "x"},
        function() require('refactoring').refactor('Inline Variable') end,
        desc = "Inline Variable",
      },
      {
        "<leader>rb",
        mode = {"n"},
        function() require('refactoring').refactor('Extract Block') end,
        desc = "Extract Block",
      },
      {
        "<leader>rbf",
        mode = {"n"},
        function() require('refactoring').refactor('Extract Block To File') end,
        desc = "Extract Block To File",
      }
    },
  }
}
