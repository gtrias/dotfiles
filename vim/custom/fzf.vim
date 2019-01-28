" FZF
" let g:fzf_command_prefix = 'FZF'
" let g:fzf_commits_log_options = '--pretty=oneline'

" let $FZF_DEFAULT_COMMAND = 'ag -g ""'

" MZove to next mayus
" map m /[A-Z]<cr><esc>:noh<return>a

nnoremap <leader><space> :GFiles<cr>
nnoremap <leader>g :GGrep<cr>
" nnoremap <leader>b :FZZZFBuffers<cr>
" nnoremap <leader>t :TestNearest<cr>
" nnoremap <leader>o :only<cr>

" Command for git grep
" - fzf#vim#grep(command, with_column, [options], [fullscreen])
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   { 'dir': systemlist('git rev-parse --show-toplevel')[0] }, <bang>0)
