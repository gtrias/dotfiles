" Solarized settings
let g:solarized_termcolors=256
"let hour = strftime("%H")
"if 6 <= hour && hour < 18
    "set background=light
"else
    "set background=dark
"endif
" colorscheme solarized
" colorscheme materialtheme
" colorscheme kkruby
" colorscheme radicalgoodspeed
colorscheme gruvbox
set background=dark

" solarized toggle background
function ToggleBackground()
    colorscheme gruvbox
    if &background == "dark"
        let &background = "light"
    else
        let &background = "dark"
    endif
endfunction

command! Togbg call ToggleBackground()
nnoremap <leader>b :call ToggleBackground()<CR>

let g:airline_powerline_fonts = 1
