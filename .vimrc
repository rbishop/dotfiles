call plug#begin('~/.vim/plugged')

Plug 'ayu-theme/ayu-vim'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'danro/rename.vim'
Plug 'ziglang/zig.vim'
Plug 'wincent/command-t'
Plug 'tpope/vim-sensible'
Plug 'ervandew/supertab'
Plug 'pocke/rbs.vim'
Plug 'preservim/nerdtree'

call plug#end()

set termguicolors
let ayucolor="dark"
colorscheme ayu

syntax on
filetype plugin indent on
set t_Co=256
set ts=2 sw=2 expandtab
set number
set autowriteall
set splitright
:au FocusLost * :wa

set cursorline
hi CursorLine cterm=NONE ctermbg=235
set cursorcolumn
hi CursorColumn cterm=NONE ctermbg=235
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
map - :Ex<CR>

autocmd Filetype go setlocal ts=4 sts=4 sw=4
autocmd Filetype rb setlocal ts=2 sts=2 sw=2
autocmd InsertLeave * if expand('%') != '' | update | endif
autocmd StdinReadPre * let s:std_in=1

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
