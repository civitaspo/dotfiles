return {
  {
    "shellRaining/hlchunk.nvim",
    event = { "UIEnter" },
    opts = {
      chunk = { enabled = true },
      -- NOTE: Disable other components to avoid conflict with other plugins (indent-blankline, mini.indentscope, ...).
      indent = { enabled = false },
      line_num = { enabled = false },
      blank = { enabled = false },
    },
  },
}
