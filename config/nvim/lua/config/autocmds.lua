-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Reload files when they are changed outside of Neovim.
vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})

-- Avoid 'E828: Cannot open undo file for writing'
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local path = vim.fn.expand("%:p")
    if #path > 200 then
      vim.opt_local.undofile = false
      vim.notify(
        "undofile disabled for long path (" .. tostring(#path) .. " chars)",
        vim.log.levels.INFO
      )
    end
  end,
})
