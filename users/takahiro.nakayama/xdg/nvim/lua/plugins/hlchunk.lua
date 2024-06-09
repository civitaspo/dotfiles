return {
  -- NOTE: Disable UI plugins to avoid conflicts with hlchunk.nvim.
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      chunk = {
        enable = true,
        notify = false,
      },
      indent = {
        enable = true,
        notify = false,
      },
      line_num = {
        enable = true,
        notify = false,
        style = "#edde7b",
      },
      blank = {
        enable = true,
        notify = false,
        chars = {
          "⇢",
        },
      },
    },
  },
}
