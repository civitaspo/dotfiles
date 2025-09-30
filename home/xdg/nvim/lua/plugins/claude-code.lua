return {
  -- {
  --   -- NOTE: <esc> is overridden by neovim global keymap, so we use <C-[> to send esc to Claude Code.
  --   "coder/claudecode.nvim",
  --   dependencies = { "folke/snacks.nvim" },
  --   opts = {
  --     terminal = {
  --       split_side = "right", -- "left" or "right"
  --       split_width_percentage = 0.30,
  --       provider = "auto", -- "auto", "snacks", "native", "external", or custom provider table
  --       auto_close = true,
  --       snacks_win_opts = {}, -- Opts to pass to `Snacks.terminal.open()` - see Floating Window section below
  --       provider_opts = {
  --         external_terminal_cmd = nil, -- Command template for external terminal provider (e.g., "alacritty -e %s")
  --       },
  --     },
  --     diff_opts = {
  --       auto_close_on_accept = true,
  --       vertical_split = true,
  --       open_in_current_tab = true,
  --       keep_terminal_focus = false, -- If true, moves focus back to terminal after diff opens
  --     },
  --   },
  --   keys = {
  --     { "<C-,>", mode = { "n", "t" }, "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
  --     { "<leader>ac", mode = { "n", "t" }, "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
  --     { "<leader>aC", mode = { "n", "t" }, "<cmd>ClaudeCodeContinue<CR>", desc = "Claude Code(Continue)" },
  --     { "<leader>ar", mode = { "n", "t" }, "<cmd>ClaudeCodeResume<CR>", desc = "Claude Code(Resume)" },
  --     { "<leader>af", mode = { "n", "t" }, "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
  --     { "<leader>ar", mode = { "n", "t" }, "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
  --     { "<leader>aC", mode = { "n", "t" }, "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
  --     { "<leader>am", mode = { "n", "t" }, "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
  --     { "<leader>ab", mode = { "n", "v" }, "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
  --     { "<leader>as", mode = { "n", "v" }, "<cmd>ClaudeCodeSend<cr>", desc = "Send to Claude" },
  --     {
  --       "<leader>as",
  --       "<cmd>ClaudeCodeTreeAdd<cr>",
  --       desc = "Add file",
  --       ft = { "snacks_picker_list", "NvimTree", "neo-tree", "oil", "minifiles",},
  --     },
  --     -- Diff management
  --     { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
  --     { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  --   },
  -- },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
  {
    "folke/sidekick.nvim",
    opts = {
      -- add any options here
      cli = {
        mux = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function()
          require("sidekick.cli").focus()
        end,
        desc = "Sidekick Switch Focus",
        mode = { "n", "v" },
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle({ focus = true })
        end,
        desc = "Sidekick Toggle CLI",
        mode = { "n", "v" },
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Sidekick Claude Toggle",
        mode = { "n", "v" },
      },
      {
        "<leader>ag",
        function()
          require("sidekick.cli").toggle({ name = "grok", focus = true })
        end,
        desc = "Sidekick Grok Toggle",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").select_prompt()
        end,
        desc = "Sidekick Ask Prompt",
        mode = { "n", "v" },
      },
    },
  },
}
