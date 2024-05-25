local lsp = require('lspconfig')

local capabilities = require('cmp_nvim_lsp').default_capabilities()
lsp.ruby_lsp.setup({
  capabilities = capabilities,
  init_options = {
    formatter = "none",
  },
})
lsp.sorbet.setup({
  capabilities = capabilities,
})

local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.rubyfmt,
  },
})

vim.api.nvim_create_augroup('AutoFormatting', {})
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.rb',
  group = 'AutoFormatting',
  callback = function()
    vim.lsp.buf.format()
  end,
})
