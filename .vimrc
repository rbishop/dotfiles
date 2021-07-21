call plug#begin('~/.vim/plugged')

Plug 'ayu-theme/ayu-vim'
Plug 'tpope/vim-endwise'
Plug 'danro/rename.vim'
Plug 'ziglang/zig.vim'
Plug 'wincent/command-t'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-vinegar'
Plug 'ervandew/supertab'

call plug#end()

set termguicolors
let ayucolor="dark"
colorscheme ayu

syntax on
filetype plugin indent on
set ts=2 sw=2 expandtab
set number
set autowriteall
set splitright
set relativenumber
:au FocusLost * :wa

let g:netrw_banner = 0
let g:netrw_browse_split = 2
let g:netrw_liststyle = 3
let g:netrw_altv = 1
let g:netrw_preview = 1
let g:netrw_winsize = -30

augroup ProjectDrawer
  autocmd!
  autocmd VimEnter * :Lexplore
augroup END

set cursorline
hi CursorLine cterm=NONE ctermbg=235
set cursorcolumn
hi CursorColumn cterm=NONE ctermbg=235
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

autocmd Filetype go setlocal ts=4 sts=4 sw=4
autocmd InsertLeave * if expand('%') != '' | update | endif
autocmd StdinReadPre * let s:std_in=1

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

set t_Co=256
