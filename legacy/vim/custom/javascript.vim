" autocmd bufwritepost *.js silent !standard --fix %
" autocmd bufwritepost *.js silent !eslint --fix %
"
" Disable typescript eslint
let g:ale_linters = {
\   'javascript': ['eslint', 'flow'],
\   'typescript': ['eslint']
\}

let b:ale_fixers = {
\   'javascript': ['eslint', 'flow'],
\   'typescript': ['tslint'],
\}
let b:ale_linters_ignore = ['tsserver']
let g:ale_fix_on_save = 1
set autoread

let g:flow#autoclose = 1
