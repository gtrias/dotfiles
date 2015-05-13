" Solarized settings
let g:solarized_termcolors=256
"let hour = strftime("%H")
"if 6 <= hour && hour < 18
    "set background=light
"else
    "set background=dark
"endif
colorscheme solarized
set background=dark

" solarized toggle background
function ToggleBackground()
    colorscheme solarized
    if &background == "dark"
        let &background = "light"
    else
        let &background = "dark"
    endif
endfunction

command! Togbg call ToggleBackground()
nnoremap <leader>b :call ToggleBackground()<CR>
inoremap <leader>b <ESC>:call ToggleBackground()<CR>
vnoremap <leader>b <ESC>:call ToggleBackground()<CR>
