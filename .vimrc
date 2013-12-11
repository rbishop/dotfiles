execute pathogen#infect()

syntax on
filetype plugin indent on
set ts=2 sw=2 expandtab
colorscheme molokai
set number

set cursorline
hi CursorLine cterm=NONE ctermbg=235
set cursorcolumn
hi CursorColumn cterm=NONE ctermbg=235
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif
