return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "gh" })
    end,
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = function()
      return {
        default_merge_method = "squash",
        picker = "telescope",
      }
    end,
    keys = {
      {"<leader>go", mode = {"n"},  "<cmd>Octo<CR>", desc = "Octo"},
    },
  },
}
