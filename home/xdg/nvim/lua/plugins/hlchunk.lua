return {
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      chunk = {
        enable = true,
        notify = false,
      },
      line_num = {
        enable = true,
        notify = false,
        style = "#edde7b",
      },
      -- NOTE: hlchunk.nvim indent & blank features are unstable. So, disable them.
      -- NOTE: I would like to use indent-blankline.nvim instead of the hlchunk.nvim indent & blank features.
      -- indent = {
      --   enable = false,
      --   notify = false,
      -- },
      -- blank = {
      --   enable = true,
      --   notify = false,
      --   chars = {
      --     "⇢",
      --   },
      -- },
    },
  },
}
