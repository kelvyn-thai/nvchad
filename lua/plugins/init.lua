return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    'nvim-lua/plenary.nvim',
  },

  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('spectre').setup()
    end,
  },

  {
    'tpope/vim-surround',
    event = "VeryLazy",
  },

  {
    'akinsho/git-conflict.nvim',
    version = "*",
    event = "VeryLazy",
    config = true,
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require('tiny-inline-diagnostic').setup({
        preset = "modern", -- Beautiful modern style
        transparent_bg = false,
        transparent_cursorline = true,
        options = {
          show_source = {
            enabled = true,
            if_many = true,
          },
          throttle = 20,
          multilines = {
            enabled = true,
            always_show = false,
          },
          overflow = {
            mode = "wrap",
            padding = 2,
          },
        },
      })
      -- Disable default virtual text to use the enhanced version
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  -- Tailwind CSS colorizer for autocompletion
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Configure nvim-cmp to work with Tailwind colorizer
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", opts = {} },
    },
    opts = function(_, opts)
      -- Use the recommended approach from the plugin documentation
      opts.formatting = {
        format = require("tailwindcss-colorizer-cmp").formatter
      }
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
