return {
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- https://github.com/numToStr/Comment.nvim
      mappings = {
        basic = false,
        extra = false,
      },
    },
    keys = {
      {
        "<leader>c/",
        mode = {"n"},
        function(...) require('Comment.api').toggle.linewise.current(...) end,
        desc = "Toggle linewise comment",
      },
      {
        "<leader>c/",
        mode = {"x"},
        function()
          local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
          vim.api.nvim_feedkeys(esc, 'nx', false)
          require('Comment.api').toggle.linewise(vim.fn.visualmode())
        end,
        desc = "Toggle linewise comment",
      },
    },
  }
}
