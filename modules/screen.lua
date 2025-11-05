local M = { followMode = false }

local function window(cb)
  local win = hs.window.focusedWindow()
  if win then
    cb(win)
    M.centerOn(win)
  end
end


function M.setFollowMode(mode)
  M.followMode = mode
  return M.followMode
end

function M.centerOn(win, force)
  if win and (M.followMode or force) then
    local frame = win:frame()
    local center = hs.geometry.point(frame.x + frame.w / 2, frame.y + frame.h / 2)
    hs.mouse.absolutePosition(center)
  end
end

function M.move(x, y, w, h)
  window(function(win)
    local current = win:screen()
    local frame = current:frame()
    win:setFrame({
      x = frame.x + frame.w * x,
      y = frame.y + frame.h * y,
      w = frame.w * w,
      h = frame.h * h
    })
  end)
end

function M.previous()
  window(function(win) win:moveToScreen(win:screen():previous()) end)
end

function M.next()
  window(function(win) win:moveToScreen(win:screen():previous()) end)
end

function M.scaleX(factor)
  window(function(win)
    local f = win:frame()
    f.w = f.w * (1 + factor)
    win:setFrame(f)
  end)
end

function M.to(index, placement)
  local screenCount = #hs.screen.allScreens()
  local resolvedIndex = (placement and placement[screenCount]) or index
  window(function(win)
    local screen = hs.screen.allScreens()[resolvedIndex + 1]
    if screen then win:moveToScreen(screen) end
  end)
end

return M
