return {
  {
    "snacks.nvim",
    opts = {
      gitbrowse = {
        what = "permalink"
      },
      terminal = {
        win = {
          keys = {
            -- NOTE: Disable default keymaps because I use Emacs keybindings.
            -- https://github.com/LazyVim/LazyVim/blob/25abbf546d564dc484cf903804661ba12de45507/lua/lazyvim/plugins/util.lua#L22-L25
            -- nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            -- nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            -- nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            -- nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
            nav_h = false,
            nav_j = false,
            nav_k = false,
            nav_l = false,
          },
        },
      },
      picker = {
        hidden = true,
        sources = {
          files = {
            hidden = true,
          },
        },
      },
    },
  },
}
