local u = require("utils")
local lspconfig = require("lspconfig")
local ts_utils = require("nvim-lsp-ts-utils")

local M = {}

M.setup = function(on_attach, capabilities)
	lspconfig.tsserver.setup({
		root_dir = lspconfig.util.root_pattern("package.json"),
		init_options = ts_utils.init_options,
		on_attach = function(client, bufnr)
			on_attach(client, bufnr)

			ts_utils.setup({
				-- debug = true,
				auto_inlay_hints = false,
				import_all_scan_buffers = 100,
				update_imports_on_move = true,
				-- filter out dumb module warning
				filter_out_diagnostics_by_code = { 80001 },
			})
			ts_utils.setup_client(client)

			u.buf_map(bufnr, "n", "gs", ":TSLspOrganize<CR>")
			u.buf_map(bufnr, "n", "gr", ":TSLspRenameFile<CR>")
			u.buf_map(bufnr, "n", "gI", ":TSLspImportAll<CR>")
		end,
		capabilities = capabilities,
	})
end

return M
