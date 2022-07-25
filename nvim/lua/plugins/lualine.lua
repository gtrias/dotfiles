local diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	sections = { "error", "warn" },
	symbols = { error = " ", warn = " " },
	colored = false,
	update_in_insert = false,
	always_visible = false,
}

local branch = {
	"branch",
	icons_enabled = true,
	icon = "",
}

local location = {
	"location",
	padding = 0,
}

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "catppuccin",
		component_separators = "",
		section_separators = "",
		always_divide_middle = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = { branch, diagnostics },
		lualine_b = {},
		lualine_c = {
			{
				"filename",
				path = 2,
			},
		},
		lualine_x = { "filetype" },
		lualine_y = { location },
		lualine_z = { "progress" },
	},
	inactive_sections = {},
	tabline = {},
	extensions = { "fugitive", "nvim-tree" },
})
