let g:vimwiki_list = [
            \ {'path': '~/src/orgmode/', 'syntax': 'markdown', 'ext': '.md', 'diary_rel_path': ''}
            \ ]
let g:vimwiki_folding = 'expr'
" let g:vimwiki_tag_format = {'pre': '\(^[ -]*tags\s*: .*\)\@<=', 'pre_mark': '', 'post_mark': '', 'sep': ','}

autocmd FileType markdown setlocal shiftwidth=2
