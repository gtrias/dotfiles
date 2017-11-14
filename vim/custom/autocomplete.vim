" neosnippet settings:
" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" Use deoplete.
let g:deoplete#enable_at_startup = 1

" deplete php - phpcd.vim
let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
let g:deoplete#ignore_sources.php = ['omni']

" Shawncplus/phpcomplete.vim confs {{
  let g:phpcomplete_search_tags_for_variables = 1
  let g:phpcomplete_parse_docblock_comments = 1
  let g:phpcomplete_enhance_jump_to_definition = 1
  let g:phpcomplete_cache_taglists = 1
" }}


" mkusher/padawan.vim {{
" :call padawan#SaveIndex()
" :call padawan#StartServer()

" }}
" PHP documenter script bound to Control-D
let g:pdv_template_dir = $HOME ."/.vim/pdv-templates"
autocmd FileType php inoremap <C-d> <ESC>:call PhpDocSingle()<CR>i
autocmd FileType php nnoremap <C-d> :call PhpDocSingle()<CR>
autocmd FileType php vnoremap <C-d> :call PhpDocRange()<CR>

" Preview window position
set splitbelow
" Autoclose preview window after selected option
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
