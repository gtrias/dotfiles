require("which-key").setup({
	plugins = {
		marks = true, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		-- the presets plugin, adds help for a bunch of default keybindings in Neovim
		-- No actual key bindings are created
		presets = {
			operators = false, -- adds help for operators like d, y, ...
			motions = false, -- adds help for motions
			text_objects = false, -- help for text objects triggered after entering an operator
			windows = true, -- default bindings on <c-w>
			nav = true, -- misc bindings to work with windows
			z = true, -- bindings for folds, spelling and others prefixed with z
			g = true, -- bindings for prefixed with g
		},
	},
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "➜", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	window = {
		border = "single", -- none, single, double, shadow
		position = "bottom", -- bottom, top
		margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left]
		padding = { 0, 0, 0, 0 }, -- extra window padding [top, right, bottom, left]
	},
	layout = {
		height = { min = 2, max = 25 }, -- min and max height of the columns
		width = { min = 10, max = 70 }, -- min and max width of the columns
		spacing = 3, -- spacing between columns
	},
	hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
	show_help = true, -- show help message on the command line when the popup is visible
})

vim.keymap.set("n", "<Space>", "<NOP>", { silent = true })
vim.g.mapleader = " "

local opts = {
	mode = "n", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = false, -- use `nowait` when creating keymaps
}

-- NvimTree
vim.keymap.set("n", "<Leader>n", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<Leader>f", ":NvimTreeFindFile<CR>", { silent = true })

-- No Highlights
vim.keymap.set("n", "<Leader>h", ":let @/=''<CR>", { silent = true })

local mappings = {
	n = "NerdTree",
	f = "Find File",
	h = "No Highlight",

	g = {
		name = "Git",
		j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
		k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
		b = { "<cmd>Git Blame<cr>", "Blame" },
	},

	l = {
		name = "LSP",
		a = { "<cmd>TroubleToggle lsp_references<cr>", "References" },
		d = { "<cmd>TroubleToggle lsp_definitions<cr>", "Definitions" },
		i = { "<cmd>LspInfo<cr>", "Info" },
		r = { "<cmd>LspRename<cr>", "Rename" },
	},

	s = {
		name = "Search",
		f = { "<cmd>FzfLua files<cr>", "Find File" },
		b = { "<cmd>FzfLua buffers<cr>", "Find buffer" },
		t = { "<cmd>FzfLua grep<cr>", "Text" },
		w = { "<cmd>FzfLua grep_cword<cr>", "Current word" },
		v = { "<cmd>FzfLua grep_visual<cr>", "Visual" },
		g = { "<cmd>FzfLua git_status<cr>", "Git status" },
		r = { "<cmd>FzfLua lsp_references<cr>", "LSP References" },
	},

	d = {
		name = "Diagnostics",
		a = { "<cmd>LspDiagLine<cr>", "Current line" },
		d = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Document" },
	},
}

local wk = require("which-key")
wk.register(mappings, opts)
