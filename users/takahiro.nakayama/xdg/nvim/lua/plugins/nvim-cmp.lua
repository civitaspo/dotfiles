return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        -- I do not want to use Emacs-like keybindings for completion.
        -- Use supertab instead.
        ['<C-f>'] = cmp.config.disable,
        ['<C-b>'] = cmp.config.disable,
        ['<C-p>'] = cmp.config.disable,
        ['<C-n>'] = cmp.config.disable,
      })
    end,
  },
};
