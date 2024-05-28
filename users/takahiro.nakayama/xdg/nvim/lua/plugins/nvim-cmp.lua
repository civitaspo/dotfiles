return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- Disable default <C-f> and <C-b> mappings
      -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
      -- ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      opts.mapping['<C-f>'] = nil
      opts.mapping['<C-b>'] = nil
    end,
  },
};
