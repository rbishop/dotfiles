execute pathogen#infect()

syntax on
filetype plugin indent on
set ts=2 sw=2 expandtab
colorscheme molokai
set number
set autowriteall
:au FocusLost * :wa

set cursorline
hi CursorLine cterm=NONE ctermbg=235
set cursorcolumn
hi CursorColumn cterm=NONE ctermbg=235
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

autocmd Filetype go setlocal ts=4 sts=4 sw=4
autocmd InsertLeave * if expand('%') != '' | update | endif

if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif
