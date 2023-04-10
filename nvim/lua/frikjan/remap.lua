vim.g.mapleader = " "

-- Modes
-- 	insert       -> i
-- 	normal       -> n
-- 	visual       -> v
-- 	visual_block -> x
-- 	command      -> c
-- 	term         -> t

-- Keys
-- 	Alt     -> A
-- 	Shift   -> S
-- 	Control -> C

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move selection up/down
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv")

-- Window navigation/resize
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set("n", "<C-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Left>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":resize +2<CR>")
