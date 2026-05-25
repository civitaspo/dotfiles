return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            -- Keep <C-k> available for kill-line in insert mode.
            { "<C-k>", mode = "i", false },
          },
        },
      },
    },
  }
}
