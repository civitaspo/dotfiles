return {
  {
    -- Require this settings to enable Kill Line in insert mode
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "<C-k>", mode = "i", false }
    end,
  }
};
