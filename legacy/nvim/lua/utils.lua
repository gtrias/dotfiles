local api = vim.api
local M = {}

local get_map_options = function(custom_options)
	local options = { noremap = true, silent = true }
	if custom_options then
		options = vim.tbl_extend("force", options, custom_options)
	end
	return options
end

M.define_augroups = function(definitions)
	for group_name, definition in pairs(definitions) do
		vim.cmd("augroup " .. group_name)
		vim.cmd("autocmd!")

		for _, def in pairs(definition) do
			local command = table.concat(vim.tbl_flatten({ "autocmd", def }), " ")
			vim.cmd(command)
		end

		vim.cmd("augroup END")
	end
end

M.command = function(name, fn)
	vim.cmd(string.format("command! %s %s", name, fn))
end

M.lua_command = function(name, fn)
	M.command(name, "lua " .. fn)
end

M.buf_map = function(bufnr, mode, target, source, opts)
	api.nvim_buf_set_keymap(bufnr or 0, mode, target, source, get_map_options(opts))
end

M.buf_command = function(bufnr, name, fn, opts)
	api.nvim_buf_create_user_command(bufnr, name, fn, opts or {})
end

M.table = {
	some = function(tbl, cb)
		for k, v in pairs(tbl) do
			if cb(k, v) then
				return true
			end
		end
		return false
	end,
}

return M
