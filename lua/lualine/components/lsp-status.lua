if require("null-ls") == nil then
	print("null-ls not found")
	return
end

local null_ls = require("null-ls")

local function list_registered_providers_names(filetype)
	local s = require("null-ls.sources")
	local available_sources = s.get_available(filetype)
	local registered = {}
	for _, source in ipairs(available_sources) do
		for method in pairs(source.methods) do
			registered[method] = registered[method] or {}
			table.insert(registered[method], source.name)
		end
	end
	return registered
end

local function list_registered(filetype)
	local registered_providers = list_registered_providers_names(filetype)
	return registered_providers[null_ls.methods.FORMATTING] or {}
end

local function lint_list_registered(filetype)
	local registered_providers = list_registered_providers_names(filetype)
	local providers_for_methods = vim.tbl_flatten(vim.tbl_map(function(m)
		return registered_providers[m] or {}
	end, {
		null_ls.methods.DIAGNOSTICS,
		null_ls.methods.DIAGNOSTICS_ON_OPEN,
		null_ls.methods.DIAGNOSTICS_ON_SAVE,
	}))

	return providers_for_methods
end

local CLspStatus = require("lualine.component"):extend()

CLspStatus.init = function(self, options)
	CLspStatus.super.init(self, options)
end

CLspStatus.update_status = function(self)
	local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
	if #buf_clients == 0 then
		return "LSP Inactive"
	end

	local buf_ft = vim.bo.filetype
	local buf_client_names = {}
	local copilot_active = false

	-- add client
	for _, client in pairs(buf_clients) do
		if client.name ~= "null-ls" and client.name ~= "copilot" then
			table.insert(buf_client_names, client.name)
		end

		if client.name == "copilot" then
			copilot_active = true
		end
	end

	local supported_formatters = list_registered(buf_ft)
	vim.list_extend(buf_client_names, supported_formatters)

	-- add linter
	local supported_linters = lint_list_registered(buf_ft)
	vim.list_extend(buf_client_names, supported_linters)

	local unique_client_names = table.concat(buf_client_names, ", ")

	local language_servers = string.format("[%s]", unique_client_names)

	if copilot_active then
		language_servers = language_servers .. "%#SLCopilot#" .. " " .. "" .. "%*"
	end
	return language_servers
end


return CLspStatus
