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
            -- TODO: The below works, but 'never_show_by_pattern' does not. Why?
            'logs',
            'objects',
            'refs'
          },
          never_show_by_pattern = {
            -- TODO: Why does this not work?
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

