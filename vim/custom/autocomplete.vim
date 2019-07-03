" neosnippet settings:
" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" Language Server
nmap <silent>gd <Plug>(coc-definition)
nmap <silent>gy <Plug>(coc-type-definition)
nmap <silent>gi <Plug>(coc-implementation)
nmap <silent>gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)

nmap <leader>Lo :CocList --normal diagnostics<cr>
nmap <leader>Ld <Plug>(coc-diagnostics-info)

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" PHP documenter script bound to Control-D
let g:pdv_template_dir = $HOME ."/.vim/pdv-templates"
autocmd FileType php inoremap <C-d> <ESC>:call PhpDocSingle()<CR>i
autocmd FileType php nnoremap <C-d> :call PhpDocSingle()<CR>
autocmd FileType php vnoremap <C-d> :call PhpDocRange()<CR>

" Preview window position
set splitbelow
" Autoclose preview window after selected option
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" Importjs
let g:deoplete_import_js#bin = 'importjs'
