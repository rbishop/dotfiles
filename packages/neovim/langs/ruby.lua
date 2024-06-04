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

lsp.standardrb.setup({
  capabilities = capabilities,
})

vim.api.nvim_create_augroup('AutoFormatting', {})
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.rb',
  group = 'AutoFormatting',
  callback = function()
    vim.lsp.buf.format()
  end,
})
