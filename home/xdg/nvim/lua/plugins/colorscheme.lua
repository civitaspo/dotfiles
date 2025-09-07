return {
  {
    "catppuccin/nvim",
    -- https://github.com/LazyVim/LazyVim/pull/6354
    optional = true,
    opts = function()
      local bufferline = require("catppuccin.groups.integrations.bufferline")
      bufferline.get = bufferline.get or bufferline.get_theme
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
