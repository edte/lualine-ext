local CFileLine = require("lualine.component"):extend()

CFileLine.init = function(self, options)
	CFileLine.super.init(self, options)
end

CFileLine.update_status = function(self)
	return string.format("%3d:%-2d", vim.fn.line("."))
end

return CFileLine
