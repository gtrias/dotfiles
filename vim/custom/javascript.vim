" autocmd bufwritepost *.js silent !standard --fix %
" autocmd bufwritepost *.js silent !eslint --fix %

let g:ale_fixers = {
\   'javascript': ['eslint'],
\}
let g:ale_fix_on_save = 1
set autoread
