local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs() 

require "nvim-treesitter.configs".setup {
  -- Managed with nixos
  -- ensure_installed = "all",
  highlight = {
    enable = true
  },
  endwise = {
    enable = true
  },
  indent = {
    enable = true
  },
}

require('cmp').setup {
  sources = {
    { name = 'nvim_lsp' }
  }
}

require ('oil').setup({})

-- load language specific LSP/formatters
require("crystal")
require("ruby")

local vim = vim

vim.api.nvim_create_augroup('AutoFormatting', {})
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.(rb|cr)',
  group = 'AutoFormatting',
  callback = function()
    vim.lsp.buf.format()
  end,
})
-- ignore neovim's default colorschemes that are in the nix package
vim.cmd([[set wildignore+=blue.vim,darkblue.vim,delek.vim,default.vim,desert.vim,elflord.vim,evening.vim,industry.vim,habamax.vim,koehler.vim,lunaperche.vim,morning.vim,murphy.vim,pablo.vim,peachpuff.vim,quiet.vim,retrobox.vim,ron.vim,shine.vim,slate.vim,sorbet.vim,torte.vim,vim.lua,wildcharm.vim,zaibatsu.vim,zellner.vim]])

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.cmd([[
  syntax on
  filetype plugin indent on
  set termguicolors
  set t_Co=256
  set ts=2 sw=2 expandtab
  set number
  set autowriteall
  set splitright
  set exrc
  set cursorline
  set cursorcolumn
  set colorcolumn=
  hi CursorLine cterm=NONE ctermbg=235
  hi CursorColumn cterm=NONE ctermbg=235
  command! Files lua require("fzf-commands").files()
  nmap <Leader>f :Files<CR>
  nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
  nnoremap <Leader>/ :nohlsearch<CR>
  autocmd InsertLeave * if expand('%') != "" | update | endif
  autocmd StdinReadPre * let s:std_in=1
  :au FocusLost * :wa
  colorscheme PaperColor
]])
