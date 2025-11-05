local M = {}

function M.log(message)
  hs.alert.closeAll()
  hs.alert.show(message)
end

return M
