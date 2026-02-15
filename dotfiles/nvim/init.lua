-- 基本設定
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.termguicolors = true

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- キーマッピング
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit", noremap = true })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Write", noremap = true })

-- Lua 設定を読み込み
require("plugins")
require("keymaps")