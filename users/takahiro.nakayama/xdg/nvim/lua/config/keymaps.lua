-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "i", "v", "n" }, "<C-f>", "<Right>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n" }, "<C-b>", "<Left>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n" }, "<C-n>", "<Down>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n" }, "<C-p>", "<Up>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n" }, "<C-e>", "<End>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n" }, "<C-a>", "<Home>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v", "n" }, "<C-h>", "<BS>", { noremap = true, silent = true })
vim.keymap.set({ "i", "v" }, "<C-d>", "<Del>", { noremap = true, silent = true }) -- <C-d> in normal mode is for scrolling down
vim.keymap.set("i", "<C-k>", "<C-o>D", { noremap = true, silent = true })
vim.keymap.set("i", "<C-u>", "<C-o>d^", { noremap = true, silent = true })
vim.keymap.set("i", "<C-w>", "<C-o>db", { noremap = true, silent = true })
vim.keymap.set("n", "<C-c>", ":q<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-x>", ":wq<CR>", { noremap = true, silent = true })
