local lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lsp.gopls.setup({
  capabilities = capabilities,
})
