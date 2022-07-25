local null_ls = require("null-ls")
local b = null_ls.builtins

local with_root_file = function(...)
	local files = { ... }
	return function(utils)
		return utils.root_has_file(files)
	end
end

local sources = {
	b.diagnostics.rubocop.with({
		condition = with_root_file(".rubocop.yml"),
		command = "bundle",
		args = { "exec", "rubocop", "-f", "json", "--stdin", "$FILENAME" },
	}),
	b.diagnostics.semgrep.with({
		condition = with_root_file(".semgrep.yml"),
	}),

	b.formatting.trim_whitespace.with({
		filetypes = { "tmux", "zsh" },
	}),
	b.formatting.rubocop.with({
		condition = with_root_file(".rubocop.yml"),
		command = "bundle",
		args = { "exec", "rubocop", "--auto-correct", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" },
	}),

	-- b.formatting.shfmt,
	-- b.formatting.stylua,
	-- b.formatting.terraform_fmt,
}

local M = {}

M.setup = function(on_attach)
	null_ls.setup({
		debug = true,
		sources = sources,
		on_attach = on_attach,
	})
end

return M
