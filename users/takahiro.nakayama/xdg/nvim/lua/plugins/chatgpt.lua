require("which-key").register({
  mode = { "n", "v" },
  ["<leader>a"] = { name = "+chatgpt" },
})

return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim"
    },
    opts = {
      -- NOTE: Set OPENAI_API_KEY environment variable.
      --       export OPENAI_API_KEY="$(op read op://Private/openai-api-key-civitaspo-neovim/password --no-newline)"
      -- api_key_cmd = 'op read op://Private/openai-api-key-civitaspo-neovim/password --no-newline',
      openai_params = {
        model = "gpt-4-turbo",
      },
      openai_edit_params = {
        model = "gpt-4-turbo",
      },
      edit_with_instructions = {
        diff = true,
        keymaps = {
          close = "<C-c>",
          accept = "<C-Enter>",
          toggle_help = "<C-q>",
          cycle_windows = "<Tab>",
          use_output_as_input = "<C-i>",
          -- disabled
          toggle_diff = "<C-\\>d",
          toggle_settings = "<C-\\>s",
        },
      },
      chat = {
        keymaps = {
          close = "<C-c>",
          yank_last = "<C-y>",
          yank_last_code = "<C-k>",
          scroll_up = "<C-u>",
          scroll_down = "<C-d>",
          new_session = "<C-o>",
          cycle_windows = "<Tab>",
          next_message = "<C-n>",
          prev_message = "<C-p>",
          select_session = "<Space>",
          rename_session = "r",
          delete_session = "d",
          draft_message = "<C-r>",
          edit_message = "e",
          delete_message = "d",
          toggle_sessions = "<C-\\> <C-\\>",
          toggle_help = "<C-q>",
          stop_generating = "<C-x>",
          -- disabled
          cycle_modes = "<C-\\>c",
          toggle_settings = "<C-\\>s",
          toggle_message_role = "<C-\\>mr",
          toggle_system_role_open = "<C-\\>sr",
        },
      },
    },
    keys = {
      {"<leader>ac", mode = {"n"},  "<cmd>ChatGPT<CR>", desc = "ChatGPT"},
      {"<leader>ae", mode = {"n", "v"}, "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction"},
      {"<leader>ag", mode = {"n", "v"}, "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction"},
      {"<leader>at", mode = {"n", "v"}, "<cmd>ChatGPTRun translate<CR>", desc = "Translate"},
      {"<leader>ak", mode = {"n", "v"}, "<cmd>ChatGPTRun keywords<CR>", desc = "Keywords"},
      {"<leader>ad", mode = {"n", "v"}, "<cmd>ChatGPTRun docstring<CR>", desc = "Docstring"},
      {"<leader>aa", mode = {"n", "v"}, "<cmd>ChatGPTRun add_tests<CR>", desc = "Add Tests"},
      {"<leader>ao", mode = {"n", "v"}, "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize Code"},
      {"<leader>as", mode = {"n", "v"}, "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize"},
      {"<leader>af", mode = {"n", "v"}, "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs"},
      {"<leader>ax", mode = {"n", "v"}, "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code"},
      {"<leader>ar", mode = {"n", "v"}, "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit"},
      {"<leader>al", mode = {"n", "v"}, "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis"},
    },
  },
}

