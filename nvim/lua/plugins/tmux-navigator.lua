vim.cmd("let g:tmux_navigator_disable_when_zoomed = 1")
vim.cmd("let g:tmux_navigator_no_mappings = 1")

vim.keymap.set("n", "<M-h>", ":TmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<M-j>", ":TmuxNavigateDown<CR>", { silent = true })
vim.keymap.set("n", "<M-k>", ":TmuxNavigateUp<CR>", { silent = true })
vim.keymap.set("n", "<M-l>", ":TmuxNavigateRight<CR>", { silent = true })
