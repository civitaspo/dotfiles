-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- modes: https://neovim.io/doc/user/map.html#map-table
--
-- n = normal
-- v = visual and select
-- s = select
-- x = visual
-- o = operator-pending
-- i = insert
-- l = insert, command-line, lang-arg
-- c = command-line
-- t = terminal

vim.keymap.set({ "i", "v", "n", "l" }, "<C-f>", "<Right>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n", "l" }, "<C-b>", "<Left>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n", "l" }, "<C-n>", "<Down>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n", "l" }, "<C-p>", "<Up>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n", "l" }, "<C-e>", "<End>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n", "l" }, "<C-a>", "<Home>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "l", "t" }, "<C-h>", "<BS>", { noremap = false, silent = true })
vim.keymap.set({ "i", "v", "l", "t" }, "<C-d>", "<Del>", { noremap = false, silent = true }) -- <C-d> in normal mode is for scrolling down
vim.keymap.set({ "n" }, "<C-c>", ":q<CR>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<C-x>", ":wq<CR>", { noremap = true, silent = true })

-- https://github.com/bsuth/emacs-bindings.nvim
vim.keymap.set({ "i", "l" }, "<C-k>", function()
  if vim.fn.mode() == "c" then
    local col = vim.fn.getcmdpos()
    local line = vim.fn.getcmdline()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(("<Delete>"):rep(#line - col + 1), true, false, true),
      "n",
      false
    )
  else
    local pos = vim.fn.getpos(".")
    local lnum = pos[2]
    local col = pos[3]
    local line = vim.fn.getline(".")
    vim.fn.setline(lnum, line:sub(1, col - 1))
  end
end, { noremap = true, silent = true })
vim.keymap.set({ "i", "l" }, "<C-u>", function()
  if vim.fn.mode() == "c" then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(("<BS>"):rep(vim.fn.getcmdpos()), true, false, true),
      "n",
      false
    )
  else
    local pos = vim.fn.getpos(".")
    local lnum = pos[2]
    local col = pos[3]
    local line = vim.fn.getline(".")
    vim.fn.setline(lnum, line:sub(col))
    vim.fn.setcharpos(".", { 0, lnum, 1, 0 })
  end
end, { noremap = true, silent = true })
