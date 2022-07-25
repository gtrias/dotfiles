local colors = require("catppuccin.api.colors").get_colors()
vim.cmd("hi def CopilotSuggestion guifg=" .. colors.pink .. " ctermfg=244")
vim.cmd("imap <silent><script><expr> <C-J> copilot#Accept('<CR>')")
vim.cmd("let g:copilot_no_tab_map = v:true")
