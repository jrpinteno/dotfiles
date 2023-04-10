-- editor options

vim.opt.mouse = "a"
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
vim.opt.cursorline = true
vim.opt.ruler = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.textwidth = 120
vim.opt.colorcolumn = "+1"
vim.opt.list = true
vim.opt.listchars = {
	tab = "▸ ",
	eol = "¬",
	trail = "·",
	extends = "#",
	nbsp = "·",
}

vim.opt.cmdheight = 3
vim.opt.pumheight = 12

-- vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.showmatch = true -- Highlight matching

-- Indentation
vim.opt.tabstop = 3
vim.opt.expandtab = false
vim.opt.shiftwidth = 3
vim.opt.shiftround = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.updatetime = 50
vim.opt.fileencoding = "utf-8"
-- Splits open down and right always
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.showtabline = 2
