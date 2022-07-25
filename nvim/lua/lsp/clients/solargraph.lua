local M = {}
local lspconfig = require("lspconfig")

M.setup = function(on_attach, capabilities)
	lspconfig.solargraph.setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

return M
