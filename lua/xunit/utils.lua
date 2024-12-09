local M = {}
local lazy = require("xunit.lazy")
local config = lazy.require("xunit.config")
local has_notify, notify = pcall(require, "notify")
local last_msg = nil

function M.debug(prefix, data)
  local pre = prefix or ""
  print(pre .. vim.inspect(data))
end

function M.send_notification(msg, status)
  if msg ~= nil and msg == last_msg then
    return
  end

  last_msg = msg

  if has_notify and config.notify then
    local title = "xUnit"
    notify(msg, status, {
      title = title,
      timeout = 5000,
    })

    vim.defer_fn(function()
      last_msg = nil
    end, 5000)
  else
    return
  end
end

return M
