return {
  {
    -- NOTE: <esc> is overridden by neovim global keymap, so we use <C-[> to send esc to Claude Code.
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      window = {
        position = "botright vsplit",
        split_ratio = 0.4,
      },
      refresh = { enable = false }, -- My neovim reloads files automatically, so I don't need this.
      git = { use_git_root = false },
      keymaps = {
        toggle = {
          normal = "<leader>ac",
          variants = {
            continue = "<leader>aC",
            resume = "<leader>ar",
          },
        },
        window_navigation = false,
        scrolling = false,
      },
    },
    keys = {
      { "<C-,>", mode = { "n" }, "<cmd>ClaudeCode<CR>", desc = "Claude Code" },
      { "<leader>ac", mode = { "n" }, "<cmd>ClaudeCode<CR>", desc = "Claude Code" },
      { "<leader>aC", mode = { "n", "v" }, "<cmd>ClaudeCodeContinue<CR>", desc = "Claude Code(Continue)" },
      { "<leader>ar", mode = { "n", "v" }, "<cmd>ClaudeCodeResume<CR>", desc = "Claude Code(Resume)" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
}
