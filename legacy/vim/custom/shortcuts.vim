" Vim php namespaces
inoremap <Leader>u <C-O>:call PhpInsertUse()<CR>
noremap <Leader>u :call PhpInsertUse()<CR>

tnoremap <Esc> <C-\><C-n>

let g:CtrlSpaceDefaultMappingKey = "<C-space> "

nmap <C-e> :NERDTreeToggle<cr>

" Tab navigation like Firefox.
nnoremap <C-S-Tab> :tabprevious<CR>
nnoremap <C-Tab>   :tabnext<CR>
nnoremap <C-t>     :tabnew<CR>
nnoremap <M>       /[A-Z]<CR>
inoremap <C-S-Tab> <Esc>:tabprevious<CR>i
inoremap <C-Tab>   <Esc>:tabnext<CR>i
inoremap <C-t>     <Esc>:tabnew<CR>

" Project grep
nnoremap <leader>g :ProjectRootExe grep<space>

" escape alias
inoremap jj <esc>
inoremap jJ <esc>
inoremap Jj <esc>
inoremap JJ <esc>

function! s:TmuxBufferName()
    let l:list = systemlist('tmux list-buffers -F"#{buffer_name}"')
    if len(l:list)==0
        return ""
    else
        return l:list[0]
    endif
endfunction

function! s:TmuxBuffer()
    return system('tmux show-buffer')
endfunction

function! s:Enable()

    if $TMUX==''
        " not in tmux session
        return
    endif

    let s:lastbname=""

    " if support TextYankPost
    if exists('##TextYankPost')==1
        " @"
        augroup vimtmuxclipboard
            autocmd!
            autocmd FocusLost * let s:lastbname=s:TmuxBufferName()
            autocmd	FocusGained   * if s:lastbname!=s:TmuxBufferName() | let @" = s:TmuxBuffer() | endif
            autocmd TextYankPost * silent! call system('tmux loadb -',join(v:event["regcontents"],"\n"))
        augroup END
        let @" = s:TmuxBuffer()
    else
        " vim doesn't support TextYankPost event
        " This is a workaround for vim
        augroup vimtmuxclipboard
            autocmd!
            autocmd FocusLost     *  silent! call system('tmux loadb -',@")
            autocmd	FocusGained   *  let @" = s:TmuxBuffer()
        augroup END
        let @" = s:TmuxBuffer()
    endif

endfunction

call s:Enable()

" " workaround for this bug
" if shellescape("\n")=="'\\\n'"
" 	let l:s=substitute(l:s,'\\\n',"\n","g")
" 	let g:tmp_s=substitute(l:s,'\\\n',"\n","g")
" 	");
" 	let g:tmp_cmd='tmux set-buffer ' . l:s
" endif
" silent! call system('tmux loadb -',l:s)

" Clear prev search
nnoremap <esc><esc> :noh<return><esc>


" Run tests
nnoremap <silent> <leader>t :w<BAR>:TestFile<CR>
nnoremap <silent> <leader>T :w<BAR>:TestNearest<CR>
nnoremap <silent> <leader>a :TestSuite<CR>
