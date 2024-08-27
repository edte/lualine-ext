local CProjectName = require("lualine.component"):extend()

-- 获取tmux窗口名称
local function getTmuxWindowName()
  local res = "nil"
  res = vim.fn.system({ "tmux", "display-message", "-p", "#W" })
  if res == nil or res == "" then
    return res
  end
  res = res:gsub("%c", "") -- 删除所有控制字符
  if res == nil or res == "" then
    return res
  end

  if res == "failed to connect to server" then
    res = ""
  end
  if res == "reattach-to-user-namespace" then
    res = ""
  end

  return res
end

-- 获取git远程仓库名称
local function getGitRemoteProjectName()
  return vim.fn.system([[git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p']])
end

-- 获取git本地仓库名称
local function getGitLocalProjectName()
  return vim.fn.system([[ TOP=$(git rev-parse --show-toplevel); echo ${TOP##*/} ]])
end

CProjectName.init = function(self, options)
  CProjectName.super.init(self, options)
end

CProjectName.update_status = function(self)
  local res = ""
  res = getTmuxWindowName()
  if res == "" then
    res = getGitRemoteProjectName()
  end
  if res == "" then
    res = getGitLocalProjectName()
  end

  res = res:gsub("%c", "") -- 删除所有控制字符
  if res == nil or res == "" then
    return res
  end

  return res
end

return CProjectName
