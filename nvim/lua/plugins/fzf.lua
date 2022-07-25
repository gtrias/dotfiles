require("fzf-lua").setup({
	lsp = {
		-- make lsp requests synchronous so they work with null-ls
		async_or_timeout = 3000,
	},
	winopts = {
		height = 0.3,
		width = 1,
		row = 1,
		col = 0,
		preview = {
			layout = "horizontal",
		},
	},
	previewers = {
		bat = {
			theme = "Catppuccin",
		},
	},
})
