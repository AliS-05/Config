return {
  -- Appearance
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "folke/tokyonight.nvim" },
  { "nvim-lualine/lualine.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-tree/nvim-tree.lua" },
  { "lewis6991/gitsigns.nvim" },

  -- Telescope and dependencies
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Utility
  { "folke/which-key.nvim" },
}

