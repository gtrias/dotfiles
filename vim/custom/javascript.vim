" autocmd bufwritepost *.js silent !standard --fix %
" autocmd bufwritepost *.js silent !eslint --fix %
"
" Disable typescript eslint
let b:ale_linters = {'typescript': ['eslint']}

let g:ale_fixers = {
\   'javascript': ['eslint'],
\   'typescript': ['tslint'],
\}
let g:ale_fix_on_save = 1
set autoread
