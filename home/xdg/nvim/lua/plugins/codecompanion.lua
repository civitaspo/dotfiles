return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "nvim-lua/plenary.nvim" },
      { "ravitemer/codecompanion-history.nvim" },
    },
    opts = {
      --Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
      strategies = {
        chat = { adapter = "claude_code" },
        inline = { adapter = "copilot" },
      },
    },
  },
};
