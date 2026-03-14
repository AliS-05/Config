vim.deprecate = function() end

-- ========================= 
-- Basics
-- =========================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.g.mapleader = " "

vim.opt.scrolloff = 999  -- keep cursor centered


-- =========================
-- LSP Configuration
-- =========================

-- !!! CURRENTLY DISABLED FOR OS DEV, DOES NOT LIKE FREESTANDING CODE !!!

-- local lspconfig = require('lspconfig')
-- 
-- -- Function to set up keymaps ONLY when an LSP is active in a buffer
-- local on_attach = function(client, bufnr)
--   local opts = { noremap=true, silent=true, buffer=bufnr }
-- 
--   -- Jump to definition
--   vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
--   -- Show documentation (Hover)
--   vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
--   -- Format code
--   vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
--   -- Rename variable globally
--   vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
--   -- Code actions (Quick fixes)
--   vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
--   -- Diagnostics (Navigate errors)
--   vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
--   vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
-- end
-- 
-- -- Configure clangd
-- lspconfig.clangd.setup({
--   on_attach = on_attach,
--   cmd = {
--     "clangd",
--     "--background-index",
--     "--clang-tidy",
--     "--header-insertion=iwyu",
--     "--completion-style=detailed",
--     "--function-arg-placeholders",
--     "--fallback-style=llvm",
--   },
-- })



-- =========================
-- :Explore mode (File system mode)
-- =========================
vim.g.nextrw_banner = 0
vim.g.netrw_liststyle = 3
vim.keymap.set("n", "<leader>e", ":Ex<CR>");

-- =========================
-- Telescope
-- =========================
require("telescope").setup {
  defaults = {
    file_ignore_patterns = { "node_modules", ".git" },
  }
}

vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })

-- =========================
-- Colorscheme cycler
-- =========================
local themes = {
  "gruvbox",
  "kanagawa-wave",
  "silentium",
  "komau"
}

local current_index = 1

local function cycle_colorscheme()
  current_index = current_index + 1
  if current_index > #themes then
    current_index = 1
  end

  vim.cmd("hi clear")
  vim.cmd("syntax enable")
  vim.o.background = "dark"

  local ok, err = pcall(vim.cmd.colorscheme, themes[current_index])
  if not ok then
    vim.notify("Failed to load colorscheme: " .. err, vim.log.levels.ERROR)
  end
end

local function toggle_background()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end

  local current_theme = vim.g.colors_name
  if current_theme then
    vim.cmd.colorscheme(current_theme)
  end
end

vim.keymap.set("n", "<leader>b", toggle_background, { desc = "Toggle light/dark mode" })
vim.keymap.set("n", "<leader>c", cycle_colorscheme, { desc = "Cycle colorscheme" })
vim.api.nvim_create_user_command("CycleColors", cycle_colorscheme, {})

local silentium = require("silentium")
silentium.setup({ accent = "#00fc7e" })
vim.cmd("colorscheme silentium")
vim.cmd("syntax enable")

-- =========================
-- Treesitter highlight fallback
-- =========================
vim.treesitter.highlighter.disable = function(_, bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return ft == "vim" or ft == "sh"
end

-- =========================
-- Persistent manual folds
-- =========================

-- Create view directory explicitly
local viewdir = vim.fn.stdpath("config") .. "/view"
vim.fn.mkdir(viewdir, "p")

vim.opt.viewdir = viewdir
vim.opt.viewoptions = { "cursor", "folds" }

-- Load view AFTER everything that might touch foldmethod
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.foldmethod = "manual"
      vim.cmd("silent! loadview")
    end
  end,
})

-- Save view when leaving window
vim.api.nvim_create_autocmd("BufWinLeave", {
  callback = function()
    if vim.bo.buftype == "" then
      vim.cmd("silent! mkview")
    end
  end,
})

-- Path to your templates folder
local template_path = vim.fn.stdpath("config") .. "/templates/"

-- Map file extensions to template filenames
local templates = {
  c   = "template.c",
  cpp = "template.cpp",
  java= "template.java",
}

-- Autocmd to insert template on new file
for ext, file in pairs(templates) do
  vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*." .. ext,
    callback = function()
      local template_file = template_path .. file
      -- Check if template file exists
      if vim.fn.filereadable(template_file) == 1 then
        vim.cmd("0r " .. template_file)  -- read template at line 0
        vim.cmd("normal! G0")           -- optional: move cursor to end/start
      end
    end
  })
end

vim.cmd('autocmd BufEnter * set formatoptions-=cro')
vim.cmd('autocmd BufEnter * setlocal formatoptions-=cro')

-- Log every save for stats viewer
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*",
  callback = function()
    local date = os.date("%Y-%m-%d")
    local file = vim.fn.expand("%:p")
    os.execute("echo " .. date .. " >> ~/.nvim_edits")
    os.execute("echo " .. file .. " >> ~/.nvim_edits")
  end
})

