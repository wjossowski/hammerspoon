local M = {}

local style = hs.alert.defaultStyle
style.textFont = "DaddyTimeMono Nerd Font"
style.textSize = 20
style.radius = 8
hs.alert.defaultStyle = style

function M.log(message, seconds)
  hs.alert.closeAll()
  hs.alert.show(message, seconds)
end

return M
