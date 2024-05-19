return {
  -- NOTE: Disable UI plugins to avoid conflicts with hlchunk.nvim.
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  {
    "shellRaining/hlchunk.nvim",
    event = { "UIEnter" },
    opts = {
      chunk = {
        notify = false,
      },
      blank = {
        chars = {
          "⇢",
        },
      },
    },
  },
}
