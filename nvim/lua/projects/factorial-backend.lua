-- Factorial Backend Linters:
--
-- rubocop (by null-ls)
-- shellcheck (by null-ls)
-- semgrep (by null-ls)
-- sorbet (by rubocop)
-- solargraph (lsp)

require'lspconfig'.solargraph.setup {
  cmd = {
      'docker-compose',
      'exec',
      'backend',
      'bundle',
      'exec',
      'solargraph',
      'stdio'
    }
}

require'lspconfig'.sorbet.setup {
  cmd = {
      'docker-compose',
      'exec',
      'backend',
      'bundle',
      'exec',
      'srb',
      'tc',
      '--lsp',
      '--disable-watchman'
    }
}

local status_null, null_ls = pcall(require, "null-ls")
if not status_null then
  return
end

-- local formatting = null_ls.builtins.formatting
-- local completion = null_ls.builtins.completion
local diagnostics = null_ls.builtins.diagnostics
local null_ls_sources = {}

table.insert(null_ls_sources, diagnostics.rubocop.with({
  command = "docker-compose exec backend bundle exec rubocop",
  timeout = 30000
}))

-- table.insert(null_ls_sources, diagnostics.shellcheck.with({
  -- command = "make shellcheck",
  -- args = { "$FILENAME" }
-- }))

-- table.insert(null_ls_sources, diagnostics.semgrep.with({
  -- command = "make semgrep",
-- }))

if #null_ls_sources ~= 0 then
  null_ls.setup({
    debug = true,
    sources = null_ls_sources,
    on_attach = function(client)
      if client.server_capabilities.document_formatting then
        vim.cmd([[
          augroup LspFormatting
          autocmd! * <buffer>
          autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 2500)
          augroup END
         ]])
      end
    end,
  })
end
