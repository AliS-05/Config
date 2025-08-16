-- Add Lazy.nvim to runtime path (adjust if you cloned lazy.nvim elsewhere)
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

vim.g.mapleader = " "

-- Load plugins from lua/plugins/init.lua
require("lazy").setup("plugins")
require("nvim-tree").setup()
vim.cmd.colorscheme("tokyonight")

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- File Explorer (NvimTree)
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
-- Telescope
keymap("n", "<leader>t", ":Telescope<CR>", opts)
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
keymap("n", "<leader>fs", ":Telescope current_buffer_fuzzy_find<CR>", opts)
-- GitSigns (next/prev hunk)
keymap("n", "<leader>gn", ":Gitsigns next_hunk<CR>", opts)
keymap("n", "<leader>gp", ":Gitsigns prev_hunk<CR>", opts)

-- Save and Quit shortcuts
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)

-- Reload config without restarting
keymap("n", "<leader>r", ":source $MYVIMRC<CR>", opts)
