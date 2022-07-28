local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  vim.notify("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua source <afile> | PackerSync
augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

return require("packer").startup(function(use)
  use({ "wbthomason/packer.nvim" })

  -- Need to load first
  use({ "lewis6991/impatient.nvim" })
  use({ "nathom/filetype.nvim" })
  use({ "nvim-lua/plenary.nvim" })
  use({ "nvim-lua/popup.nvim" })
  use({ "kyazdani42/nvim-web-devicons" })

  -- LSP
  use({
    "neovim/nvim-lspconfig", -- A collection of common configurations for Neovim's built-in language server client.
  })
  use "williamboman/nvim-lsp-installer" -- simple to use language server installer

  -- Dynamic project configuration
  use ({
    "windwp/nvim-projectconfig"
  })
  use('lspcontainers/lspcontainers.nvim')

  -- Illuminate
  use({
    "RRethy/vim-illuminate",
    config = function()
      require("plugins/vim-illuminate")
    end,
  }) -- Illuminates current word in the document

  -- Fuzzy finder
  use({ "junegunn/fzf", run = "./install --all" })
  use({
    "ibhagwan/fzf-lua",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("plugins/fzf")
    end,
  })

  -- Autocomplete
  use({
    "hrsh7th/nvim-cmp",
    config = function()
      require("plugins/nvim-cmp")
    end,
  })
  use({ "hrsh7th/cmp-path" })
  use({ "hrsh7th/cmp-nvim-lsp" })
  use({ "hrsh7th/cmp-buffer" })
  use({ "hrsh7th/cmp-vsnip" })
  use({ "onsails/lspkind-nvim" })

  -- Snippets
  use({ "hrsh7th/vim-vsnip" })
  use({ "hrsh7th/vim-vsnip-integ" })
  use({ "rafamadriz/friendly-snippets" })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("plugins/nvim-treesitter")
    end,
  })
  use({ "nvim-treesitter/nvim-treesitter-textobjects" })

  -- Color
  use({
    "catppuccin/nvim",
    as = "catppuccin",
    config = function()
      require("plugins/catppuccin")
    end,
  })

  -- Gitsigns
  use({
    "lewis6991/gitsigns.nvim",
    config = function()
      require("plugins/gitsigns")
    end,
  })

  -- Whichkey
  use({
    "folke/which-key.nvim",
    config = function()
      require("plugins/which-key")
    end,
  })

  -- Comments
  use({
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  })

  -- Show indent lines
  use({
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("plugins/indent-blankline")
    end,
  })

  -- Diagnostics
  use({
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    cmd = "TroubleToggle",
    config = function()
      require("plugins/trouble")
    end,
  })

  -- Better quickfix
  use({
    "kevinhwang91/nvim-bqf",
    ft = "qf",
  })

  -- LSP addons
  use({ "jose-elias-alvarez/nvim-lsp-ts-utils" })
  use({ "jose-elias-alvarez/null-ls.nvim" })

  -- Explorer
  use({
    "kyazdani42/nvim-tree.lua",
    requires = {
      "kyazdani42/nvim-web-devicons", -- optional, for file icon
    },
    config = function()
      require("plugins/nvim-tree")
    end,
  })
  -- nerdtree replacement
  use "preservim/nerdtree"

  -- Colorize hex values
  use("ap/vim-css-color")

  -- Modify faster (){}[] contents
  use("wellle/targets.vim")

  -- Find and replace
  use("nvim-pack/nvim-spectre")

  -- Status Line
  use({
    "hoob3rt/lualine.nvim",
    config = function()
      require("plugins/lualine")
    end,
  })

  -- Copilot
  use({
    "github/copilot.vim",
    config = function()
      require("plugins/copilot")
    end,
  })

  -- Git
  use("tpope/vim-fugitive")

  -- Others
  use("tommcdo/vim-exchange")
  use("tpope/vim-surround") -- Use more
  use("tpope/vim-repeat")
  use({
    "christoomey/vim-tmux-navigator",
    config = function()
      require("plugins/tmux-navigator")
    end,
  })
  use({
    "cappyzawa/trim.nvim",
    config = function()
      require("trim").setup()
    end,
  })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
