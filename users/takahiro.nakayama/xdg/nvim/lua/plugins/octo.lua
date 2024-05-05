-- TODO: Under construction...
require("which-key").register({
  mode = { "n" },
  -- https://github.com/LazyVim/LazyVim/issues/1955
  ["<leader>o"] = { name = "+octo" },
  -- https://github.com/pwntester/octo.nvim/blob/5646539320cd62af6ff28f48ec92aeb724c68e18/lua/octo/commands.lua#L47-L344
  ["<leader>oi"] = { name = "+issue" },
  ["<leader>op"] = { name = "+pull_request" },
  ["<leader>or"] = { name = "+review" },
  ["<leader>ora"] = { name = "+reaction" },
  ["<leader>ot"] = { name = "+thread" },
  ["<leader>oc"] = { name = "+comment" },
})

return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "gh" })
    end,
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = function()
      return {
        default_merge_method = "squash",
        picker = "telescope",
      }
    end,
    keys = {
      -- TODO: Reduce possible actions.
      {"<leader>oa", mode = {"n"}, function () require("octo.commands").commands.actions() end, desc = "Search octo actions"},
      -- Issue commands
      {"<leader>oin", mode = {"n"}, function (...) require("octo.commands").commands.issue.create(...) end, desc = "Create issue"},
      {"<leader>oie", mode = {"n"}, function (...) require("octo.commands").commands.issue.edit(...) end, desc = "Edit issue"},
      {"<leader>oix", mode = {"n"}, function () require("octo.commands").commands.issue.close() end, desc = "Close issue"},
      {"<leader>oio", mode = {"n"}, function () require("octo.commands").commands.issue.reopen() end, desc = "Reopen issue"},
      {"<leader>oil", mode = {"n"}, function (...) require("octo.commands").commands.issue.list(...) end, desc = "List issues"},
      {"<leader>oir", mode = {"n"}, function () require("octo.commands").commands.issue.reload() end, desc = "Reload issue"},
      {"<leader>oi/", mode = {"n"}, function (...) require("octo.commands").commands.issue.search(...) end, desc = "Search issues"},
      {"<leader>oiy", mode = {"n"}, function () require("octo.commands").commands.issue.url() end, desc = "Copy issue URL"},
      {"<leader>oib", mode = {"n"}, function () require("octo.commands").commands.issue.browser() end, desc = "Open issue in browser"},
      -- PR commands
      {"<leader>ope", mode = {"n"}, function (...) require("octo.commands").commands.pr.edit(...) end, desc = "Edit PR"},
      {"<leader>opx", mode = {"n"}, function () require("octo.commands").commands.pr.close() end, desc = "Close PR"},
      {"<leader>opo", mode = {"n"}, function () require("octo.commands").commands.pr.reopen() end, desc = "Reopen PR"},
      {"<leader>opl", mode = {"n"}, function (...) require("octo.commands").commands.pr.list(...) end, desc = "List PRs"},
      {"<leader>opco", mode = {"n"}, function () require("octo.commands").commands.pr.checkout() end, desc = "Checkout PR"},
      {"<leader>opn", mode = {"n"}, function (...) require("octo.commands").commands.pr.create(...) end, desc = "Create PR"},
      {"<leader>opcm", mode = {"n"}, function () require("octo.commands").commands.pr.commits() end, desc = "Show PR Commits"},
      {"<leader>opch", mode = {"n"}, function () require("octo.commands").commands.pr.changes() end, desc = "Show PR Changed Files"},
      {"<leader>opd", mode = {"n"}, function () require("octo.commands").commands.pr.diff() end, desc = "Show PR Diff"},
      {"<leader>opm", mode = {"n"}, function (...) require("octo.commands").commands.pr.merge(...) end, desc = "Merge PR"},
      {"<leader>opck", mode = {"n"}, function () require("octo.commands").commands.pr.checks() end, desc = "Show PR Checks"},
      {"<leader>opsr", mode = {"n"}, function () require("octo.commands").commands.pr.ready() end, desc = "Ready for review"},
      {"<leader>opsd", mode = {"n"}, function () require("octo.commands").commands.pr.draft() end, desc = "Draft"},
      {"<leader>op/", mode = {"n"}, function (...) require("octo.commands").commands.pr.search(...) end, desc = "Search PRs"},
      {"<leader>opr", mode = {"n"}, function () require("octo.commands").commands.pr.reload() end, desc = "Reload PR"},
      {"<leader>opy", mode = {"n"}, function () require("octo.commands").commands.pr.url() end, desc = "Copy PR URL"},
      {"<leader>opb", mode = {"n"}, function () require("octo.commands").commands.pr.browser() end, desc = "Open PR in browser"},
      -- Review commands
      {"<leader>orn", mode = {"n"}, function () require("octo.commands").commands.review.start() end, desc = "Start review"},
      {"<leader>orr", mode = {"n"}, function () require("octo.commands").commands.review.resume() end, desc = "Resume review"},
      {"<leader>or/", mode = {"n"}, function () require("octo.commands").commands.review.comments() end, desc = "Show review comments"},
      {"<leader>ors", mode = {"n"}, function () require("octo.commands").commands.review.submit() end, desc = "Submit review"},
      {"<leader>ord", mode = {"n"}, function () require("octo.commands").commands.review.discard() end, desc = "Discard review"},
      {"<leader>orx", mode = {"n"}, function () require("octo.commands").commands.review.close() end, desc = "Close review"},
      {"<leader>orc", mode = {"n"}, function () require("octo.commands").commands.review.commit() end, desc = "Commit review"},
      -- Reaction commands
      {"<leader>orat", mode = {"n"}, function () require("octo.commands").commands.reaction.thumbs_up() end, desc = "Add thumbs up"},
      {"<leader>orad", mode = {"n"}, function () require("octo.commands").commands.reaction.thumbs_down() end, desc = "Add thumbs down"},
      {"<leader>oral", mode = {"n"}, function () require("octo.commands").commands.reaction.laugh() end, desc = "Add laugh"},
      {"<leader>orae", mode = {"n"}, function () require("octo.commands").commands.reaction.eyes() end, desc = "Add eyes"},
      {"<leader>orac", mode = {"n"}, function () require("octo.commands").commands.reaction.confused() end, desc = "Add confused"},
      {"<leader>orah", mode = {"n"}, function () require("octo.commands").commands.reaction.hooray() end, desc = "Add hooray"},
      -- Thread commands
      {"<leader>otr", mode = {"n"}, function () require("octo.commands").commands.thread.resolve() end, desc = "Resolve thread"},
      {"<leader>otu", mode = {"n"}, function () require("octo.commands").commands.thread.unresolve() end, desc = "Unresolve thread"},
      -- Comment commands
      {"<leader>oca", mode = {"n"}, function () require("octo.commands").commands.comment.add() end, desc = "Add comment"},
      {"<leader>ocd", mode = {"n"}, function () require("octo.commands").commands.comment.delete() end, desc = "Delete comment"}
    },
  },
}
