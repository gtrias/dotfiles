" Vim php namespaces
inoremap <Leader>u <C-O>:call PhpInsertUse()<CR>
noremap <Leader>u :call PhpInsertUse()<CR>

tnoremap <Esc> <C-\><C-n>

let g:CtrlSpaceDefaultMappingKey = "<C-space> "

" Nerdtree toggle
nmap <C-e> :NERDTreeToggle<cr>
