-- This is not working
vim.cmd("let g:Illuminate_ftblacklist = ['NvimTree']")
require("utils").define_augroups({
	_illuminateWord = {
		{
			"VimEnter",
			"*",
			"hi illuminatedWord cterm=underline gui=underline",
		},
	},
})
