return {
  -- NOTE: Disable UI plugins to avoid conflicts with hlchunk.nvim.
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  { "echasnovski/mini.indentscope", enabled = false },
  {
    "shellRaining/hlchunk.nvim",
    event = { "UIEnter" },
    opts = {
    },
  },
}
