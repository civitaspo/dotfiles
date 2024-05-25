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
vim.keymap.set({ "i", "v", "n", "l" }, "<C-b>", "<Left>",  { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n", "l" }, "<C-n>", "<Down>",  { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n", "l" }, "<C-p>", "<Up>",    { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n", "l" }, "<C-e>", "<End>",   { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n", "l" }, "<C-a>", "<Home>",  { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "l" },      "<C-h>", "<BS>",    { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "l" },      "<C-d>", "<Del>",   { noremap = true, silent = true }) -- <C-d> in normal mode is for scrolling down
vim.keymap.set({ "i", "l" },           "<C-k>", "<C-o>D",  { noremap = true, silent = true })
vim.keymap.set({ "i", "l" },           "<C-u>", "<C-o>d^", { noremap = true, silent = true })
vim.keymap.set({ "n" },                     "<C-c>", ":q<CR>",  { noremap = true, silent = true })
vim.keymap.set({ "n" },                     "<C-x>", ":wq<CR>", { noremap = true, silent = true })
