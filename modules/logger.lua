local M = {}

M.images = {
  terry = hs.image.imageFromPath("~/.hammerspoon/assets/terry.webp")
      :setSize({ w = 640, h = 631 }),
  bambus = hs.image.imageFromPath("~/.hammerspoon/assets/sebcel.png")
      :setSize({ w = 612, h = 572 })
}

local style = hs.alert.defaultStyle
style.textFont = "DaddyTimeMono Nerd Font"
style.textSize = 20
style.radius = 8
hs.alert.defaultStyle = style

function M.log(message, seconds)
  hs.alert.closeAll()
  hs.alert.show(message, seconds)
end

function M.logImage(message, image, seconds)
  hs.alert.closeAll()
  hs.alert.showWithImage(message, image:setSize({ w = 64, h = 64 }), nil, nil, seconds)
end

function M.logImageBelow(message, image, seconds)
  hs.alert.closeAll()

  local screenFrame = hs.screen.mainScreen():frame()

  local canvas = hs.canvas.new({
    w = 300,
    h = 200,
    x = screenFrame.x + (screenFrame.w - 300) / 2,
    y = screenFrame.y + (screenFrame.h - 200) / 2,
  })

  canvas[1] = {
    type = "rectangle",
    action = "fillAndStroke",
    fillColor = style.fillColor,
    strokeColor = { white = 1, alpha = 1 },
    strokeWidth = style.borderWidth or 2,
    roundedRectRadii = { xRadius = style.radius, yRadius = style.radius },
  }

  canvas[2] = {
    type = "text",
    text = message,
    textFont = style.textFont,
    textSize = style.textSize,
    textColor = style.textColor,
    frame = { x = "5%", y = "10%", w = "90%", h = "40%" },
    textAlignment = "center"
  }

  -- Obrazek pod tekstem
  canvas[3] = {
    type = "image",
    image = image or M.images.bambus,
    imageScaling = "scaleProportionally",
    frame = { x = "35%", y = "40%", w = "30%", h = "35%" }
  }

  canvas:show()
  hs.timer.doAfter(seconds or 2, function() canvas:delete() end)
end

return M
