" Vim php namespaces
inoremap <Leader>u <C-O>:call PhpInsertUse()<CR>
noremap <Leader>u :call PhpInsertUse()<CR>

tnoremap <Esc> <C-\><C-n>

let g:CtrlSpaceDefaultMappingKey = "<C-space> "

nmap <C-e> :NERDTreeToggle<cr>

" Tab navigation like Firefox.
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
nnoremap <C-t>     :tabnew<CR>
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i
inoremap <C-t>     <Esc>:tabnew<CR>

" Project grep
nnoremap <leader>g :ProjectRootExe grep<space>
