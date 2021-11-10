set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

lua require('plugins')
lua require('flow')
lua require('sorbet')
lua require('setup_lsp')
autocmd BufWritePost plugins.lua PackerCompile

source ~/.vimrc
