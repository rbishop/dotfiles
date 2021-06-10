call plug#begin('~/.vim/plugged')

Plug 'ayu-theme/ayu-vim'
Plug 'preservim/nerdtree'
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

set cursorline
hi CursorLine cterm=NONE ctermbg=235
set cursorcolumn
hi CursorColumn cterm=NONE ctermbg=235
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

autocmd Filetype go setlocal ts=4 sts=4 sw=4
autocmd InsertLeave * if expand('%') != '' | update | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

let NERDTreeShowHidden=1
set t_Co=256
