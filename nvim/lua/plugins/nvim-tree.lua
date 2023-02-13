local colors = require("catppuccin.palettes").get_palette()
vim.cmd("highlight NvimTreeGitNew gui=NONE guifg=" .. colors.green .. " guibg=NONE")

require("nvim-tree").setup({
    open_on_setup = false,
    view = {
        mappings = {
            list = {
                { key = "s", action = "vsplit" },
                { key = "i", action = "split" },
                { key = "p", action = "parent_node" },
            },
        },
    },
    renderer = {
        indent_markers = {
            enable = true,
        },
        highlight_git = true,
        add_trailing = true,
        special_files = {
            "README.md",
            "Gemfile",
            "package.json",
        },
        icons = {
            webdev_colors = true,
            show = {
                git = false,
                folder = true,
                file = true,
                folder_arrow = false,
            },
        },
    },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
    },
    actions = {
        open_file = {
            window_picker = {
                enable = false,
            },
        },
    },
})
