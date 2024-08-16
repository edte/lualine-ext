if try_require 'tmux-status' == nil then
  print 'tmux-status not found'
  return
end

local CTmuxStatus = require("lualine.component"):extend()

CTmuxStatus.init = function(self, options)
	CTmuxStatus.super.init(self, options)
end

CTmuxStatus.update_status = function(self)
  local res = 'nil'
  res = vim.fn.system { 'tmux', 'display-message', '-p', '#W' }
  res = res:gsub('%c', '') -- 删除所有控制字符
  -- print(res)
  return res
end

return CTmuxStatus
