local M = {}

function M.log(message, seconds)
  hs.alert.closeAll()
  hs.alert.show(message, seconds)
end

return M
