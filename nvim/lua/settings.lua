---  HELPERS  ---
local cmd = vim.cmd
local opt = vim.opt

---  VIM ONLY COMMANDS  ---
cmd("filetype plugin on") -- filetype detection
cmd("set inccommand=nosplit") -- show what you are substituting in real time
cmd("set iskeyword+=-") -- treat dash as a separate word
cmd("set synmaxcol=200") -- Limits the syntax highlighting

--- COLORSCHEME ---
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.syntax = true
cmd([[colorscheme catppuccin]])

-- SETTINGS
opt.backup = false -- creates a backup file
opt.cmdheight = 1 -- more space in the neovim command line for displaying messages
opt.colorcolumn = "99999" -- fix indentline for now
opt.completeopt = { "menu", "menuone" } -- TODO: Test
opt.conceallevel = 0 -- so that `` is visible in markdown files
opt.fileencoding = "utf-8" -- the encoding written to a file
opt.guifont = "JetBrains Mono Nerd Font Complete:h14"
opt.hidden = true -- required to keep multiple buffers and open multiple buffers
opt.hlsearch = true -- highlight all matches on previous search pattern
opt.ignorecase = true -- ignore case in search patterns
opt.mouse = "a" -- allow the mouse to be used in neovim
opt.pumheight = 10 -- pop up menu height
opt.showcmd = false -- show the number of lines selected
opt.showmode = false -- we don't need to see things like -- INSERT -- anymore
opt.showtabline = 1 -- always show tabs
opt.smartcase = true -- smart case
opt.smartindent = true -- make indenting smarter again
opt.swapfile = false -- creates a swapfile
opt.timeoutlen = 100 -- time to wait for a mapped sequence to complete (in milliseconds)
opt.title = true -- set the title of window to the value of the titlestring
opt.titlestring = "%<%F%=%l/%L - nvim" -- what the title of the window will be set to
opt.undofile = true -- enable persisten undo
opt.updatetime = 300 -- faster completion
opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
opt.shortmess:append("c") -- don't pass messages to |ins-completion-menu|
opt.laststatus = 3 -- show a unique status bar across all windows

-- Tabs and spaces: Overwritte in ftplugins
opt.shiftwidth = 2 -- the number of spaces inserted for each indentation
opt.tabstop = 2 -- insert 2 spaces for a tab
opt.softtabstop = 2 -- TODO: document
opt.expandtab = true -- convert tabs to spaces

opt.cursorline = true -- highlight the current line
opt.number = true -- set numbered lines
opt.relativenumber = false -- set relative numbered lines
opt.signcolumn = "yes" -- always show the sign column, otherwise it would shift the text each time
opt.wrap = false -- display lines as one long line
opt.scrolloff = 4 -- number of lines before scrolling
opt.sidescrolloff = 2 -- number of cols before scrolling

-- CUSTOM
-- TODO: Port to lua
cmd("set wildmode=list:longest,list:full") -- Show menu with possible tab competions
cmd("set wildignore+=.git,.svn")
cmd("set wildignore+=*.o,*.obj,*.jpg,*.png,*.gif,*.log,*.gz,*.bin,*.gem,*.rbc,*.class")
cmd("set wildignore+=*.min.js,**/node_modules/**,**/images/**")
cmd("set wildignore+=**/assets/**/original/**,**/assets/**/thumb/**,**/assets/**/small/**")
cmd("set wildignore+=tmp,public,vendor/bundle/*,vendor/cache/*,test/fixtures/*,vendor/gems/*,spec/cov,a/*")
cmd("set wildignore+=sorbet/*")
