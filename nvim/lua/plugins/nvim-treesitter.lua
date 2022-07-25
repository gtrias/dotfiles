require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"css",
		"graphql",
		"html",
		"javascript",
		"jsdoc",
		"json",
		"lua",
		"markdown",
		"ruby",
		"scss",
		"toml",
		"typescript",
		"yaml",
	},
	highlight = {
		enable = true, -- false will disable the whole extension
		additional_vim_regex_highlighting = true,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<CR>",
			scope_incremental = "<CR>",
			node_incremental = "<TAB>",
			node_decremental = "<S-TAB>",
		},
	},
	-- nvim-treesitter-textobjects
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
	},
})
