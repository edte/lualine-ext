local CProjectName = require("lualine.component"):extend()

local function getProjectName()
  local res = vim.fn.system({ "tmux", "display-message", "-p", "#W" }):gsub("%c", "")
  if res ~= "" and res ~= "failed to connect to server" and res ~= "reattach-to-user-namespace" then
    -- print("tmux")
    return res
  end

  if vim.fn.system([[git rev-parse --show-toplevel 2> /dev/null]]) == "" then
    -- print("pwd")
    return vim.fn.system("basename $(pwd)"):gsub("%c", "")
  end

  res = vim.fn.system([[git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p']]):gsub("%c", "")
  if res ~= "" then
    -- print("git remote")
    return res
  end

  -- print("git local")
  return vim.fn.system([[ TOP=$(git rev-parse --show-toplevel); echo ${TOP##*/} ]]):gsub("%c", "")
end

-- TOOD: 这里会多次调用，应该缓存一下, 看用vimenter咋优化
-- 从test进入neovim再切回来，cwd/pwd不会变，还是config的路径，待修复
local default_options = {
  project_name = getProjectName(),
}

CProjectName.init = function(self, options)
  CProjectName.super.init(self, options)
  self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)

  local group_id = vim.api.nvim_create_augroup("get_project_name", { clear = true })
  local au = vim.api.nvim_create_autocmd

  au({ "BufEnter" }, {
    group = group_id,
    pattern = "*",
    callback = function()
      if vim.bo.filetype == "minifiles" or vim.bo.filetype == "alpha" then
        return
      end

      self.options.project_name = getProjectName()
      -- print("read: " .. self.options.project_name)
    end,
  })
end

CProjectName.update_status = function(self)
  -- print("status")
  return self.options.project_name
end

return CProjectName
