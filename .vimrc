execute pathogen#infect()

syntax on
filetype plugin indent on
set ts=2 sw=2 expandtab
colorscheme halflife
set number
set autowriteall
set splitright
:au FocusLost * :wa

set cursorline
hi CursorLine cterm=NONE ctermbg=235
set cursorcolumn
hi CursorColumn cterm=NONE ctermbg=235
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

autocmd Filetype go setlocal ts=4 sts=4 sw=4
autocmd InsertLeave * if expand('%') != '' | update | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

let NERDTreeShowHidden=1

if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif
