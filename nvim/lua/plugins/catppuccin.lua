vim.g.catppuccin_flavour = "mocha"

require("catppuccin").setup({
    compile = { enabled = true },
    integrations = {
        treesitter = true,
        native_lsp = { enabled = true },
        gitsigns = true,
        which_key = true,
        nvimtree = true,
        indent_blankline = {
            enabled = true,
            colored_indent_levels = true,
        },
    },
})
vim.cmd [[colorscheme catppuccin]]
