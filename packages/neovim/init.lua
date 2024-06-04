local vim = vim

require('ayu').setup({})
require('ayu').colorscheme('dark')

require('cmp').setup {
  sources = {
    { name = 'nvim_lsp' }
  }
}

require("ruby")

vim.cmd([[
  set termguicolors
  syntax on
  filetype plugin indent on
  set t_Co=256
  set ts=2 sw=2 expandtab
  set number
  set autowriteall
  set splitright
  :au FocusLost * :wa
  set exrc
  set cursorline
  hi CursorLine cterm=NONE ctermbg=235
  set cursorcolumn
  hi CursorColumn cterm=NONE ctermbg=235
  nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
  nnoremap <Leader>/ :nohlsearch<CR>
  command! Files lua require("fzf-commands").files()
  nmap <Leader>f :Files<CR>
  map - :Ex<CR>
  autocmd Filetype go setlocal ts=4 sts=4 sw=4
  autocmd Filetype rb setlocal ts=2 sts=2 sw=2
  autocmd InsertLeave * if expand('%') != "" | update | endif
  autocmd StdinReadPre * let s:std_in=1
]])
