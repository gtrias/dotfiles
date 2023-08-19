-- local colors = require("catppuccin.api.colors").get_colors()
-- vim.cmd("hi def GitSignsCurrentLineBlame guifg=" .. colors.overlay2 .. " ctermfg=244")

require("gitsigns").setup({
    signs = {
        add = { test = "▎" },
        change = { text = "▎" },
        delete = { text = "▎" },
        topdelete = { text = "▎" },
        changedelete = { text = "▎" },
    },
    current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_formatter = "[<abbrev_sha>] <author>, <author_time:%Y-%m-%d> - <summary>",
})
