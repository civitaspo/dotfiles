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
        -- https://github.com/hrsh7th/nvim-cmp/blob/a110e12d0b58eefcf5b771f533fc2cf3050680ac/lua/cmp/config/mapping.lua#L44
        ['<C-p>'] = cmp.config.disable,
        ['<C-n>'] = cmp.config.disable,
        ['<Up>'] = cmp.config.disable,
        ['<Down>'] = cmp.config.disable,
      })
    end,
  },
};
