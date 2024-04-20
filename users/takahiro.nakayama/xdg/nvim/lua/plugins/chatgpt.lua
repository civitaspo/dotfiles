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
      api_key_cmd = 'op read op://Private/openai-api-key-civitaspo-neovim/password --no-newline',
      openai_params = {
        model = "gpt-4-turbo",
        -- max_tokens = 128000,
      },
      openai_edit_params = {
        model = "gpt-4-turbo",
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

