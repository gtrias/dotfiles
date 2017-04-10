" Disable syntastic for html files
let g:syntastic_disabled_filetypes=['html, ctp']
let g:syntastic_auto_jump               = 0
let g:syntastic_error_symbol            = '✖'
let g:syntastic_warning_symbol          = '►'
let g:syntastic_style_error_symbol = "✗"
let g:syntastic_style_warning_symbol = "⚠"
let g:syntastic_php_phpcs_args="--standard=Symfony2"
let g:syntastic_javascript_checkers = ['eslint']
