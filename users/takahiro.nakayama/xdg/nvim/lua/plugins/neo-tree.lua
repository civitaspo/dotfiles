return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            '.git',
          },
          hide_by_pattern = {},
          never_show = {
            '.DS_Store',
            '.terraform',
          },
          never_show_by_pattern = {
            '.git/logs/**',
            '.git/objects/**',
            '.git/refs/**',
          },
        },
      },
      group_empty_dirs = true,
    },
  },
}

