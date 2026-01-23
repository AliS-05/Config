-- =========================
-- Basics
-- =========================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.g.mapleader = " "

vim.opt.scrolloff = 999  -- keep cursor centered

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
  "deepwhite",
  "tokyonight-night",
  "tokyonight-day",
  "rose-pine",
  "catppuccin-mocha",
  "catppuccin-latte",
  "catppuccin-frappe",
  "kanagawa-wave",
  "kanagawa-lotus",
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

vim.cmd("colorscheme kanagawa")
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

