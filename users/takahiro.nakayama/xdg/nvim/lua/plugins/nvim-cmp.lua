return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        -- I do not want to use Emacs-like keybindings for completion.
        -- Use supertab instead.
        ['<C-F>'] = cmp.config.disable,
        ['<C-B>'] = cmp.config.disable,
        -- https://github.com/hrsh7th/nvim-cmp/blob/a110e12d0b58eefcf5b771f533fc2cf3050680ac/lua/cmp/config/mapping.lua#L44
        ['<C-P>'] = cmp.config.disable,
        ['<C-N>'] = cmp.config.disable,

        -- Use <S-CR> instead of <C-N>
        -- https://github.com/LazyVim/LazyVim/blob/b47c65f4087c4d82720ab7439f395aba5d6b5f40/lua/lazyvim/plugins/coding.lua#L39
        ["<S-CR>"] = cmp.mapping(function()
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        end, { "i", "s" }),
      })
    end,
  },
};
