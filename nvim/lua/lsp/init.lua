local lspconfig = require("lspconfig")
local u = require("utils")
local lsp = vim.lsp

local border_opts = { border = "rounded", focusable = false }
local signs = {
	{ name = "DiagnosticSignError", text = "" },
	{ name = "DiagnosticSignWarn", text = "" },
	{ name = "DiagnosticSignHint", text = "" },
	{ name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
	vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

vim.diagnostic.config({
	virtual_text = true,
	signs = { active = signs },
	underline = true,
	update_in_insert = true,
	severity_sort = true,
	float = border_opts,
})

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, border_opts)

--[[
local lsp_formatting = function(bufnr)
	local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
	lsp.buf.format({
		bufnr = bufnr,
		filter = function(client)
			if client.name == "eslint" then
				return true
			end

			if client.name == "null-ls" then
				return not u.table.some(clients, function(_, other_client)
					return other_client.name == "eslint"
				end)
			end
		end,
	})
end
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
--]]

local on_attach = function(client, bufnr)
	u.buf_command(bufnr, "LspHover", vim.lsp.buf.hover)
	u.buf_command(bufnr, "LspDiagPrev", vim.diagnostic.goto_prev)
	u.buf_command(bufnr, "LspDiagNext", vim.diagnostic.goto_next)
	u.buf_command(bufnr, "LspDiagLine", vim.diagnostic.open_float)
	u.buf_command(bufnr, "LspTypeDef", vim.lsp.buf.type_definition)
	u.buf_command(bufnr, "LspRename", function()
		vim.lsp.buf.rename()
	end)

	u.buf_map(bufnr, "n", "K", ":LspHover<CR>")
	u.buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>")
	u.buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>")
	u.buf_map(bufnr, "n", "gh", ":LspTypeDef<CR>")

    --[[
	if client.supports_method("textDocument/formatting") then
		u.buf_command(bufnr, "LspFormatting", function()
			lsp_formatting(bufnr)
		end)

		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			command = "LspFormatting",
		})
	end
    --]]

	require("illuminate").on_attach(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

local servers = {
	"tsserver",
	"eslint",
	"sorbet",
	"solargraph",
	"sumneko_lua",
	"null-ls",
}

for _, server in pairs(servers) do
	require("lsp.clients." .. server).setup(on_attach, capabilities)
end
