-- Inspired by: https://github.com/arkav/lualine-lsp-progress

local CTimeLine = require('lualine.component'):extend()

CTimeLine.init = function(self, options)
	CTimeLine.super.init(self, options)
end

CTimeLine.update_status = function(self)
    return os.date(self.options.format or "%Y-%m-%d", os.time())
end

return CTimeLine
