local logger = require('modules.logger')
local screen = require("modules.screen")

local M      = {}

local function flag(label, isOn)
  return '\n  ' .. label .. ' : ' .. (isOn and 'on' or 'off')
end

function M.setup(profile, mods, apps)
  local work = true
  local napravelo = true
  local distractors = true
  local follow = false

  hs.hotkey.bind(mods.pos, '1', function()
    logger.log("SETUP:" ..
      flag('follow', follow) ..
      flag('distractors', distractors) ..
      flag('work', work) ..
      flag('napravelo', napravelo)
    )
  end)

  hs.hotkey.bind(mods.pos, profile['silent'], function()
    distractors = not distractors
    logger.log("Distractors: " .. (distractors and ' ON' or 'OFF'))
  end)

  hs.hotkey.bind(mods.pos, profile['napravelo'], function()
    napravelo = not napravelo
    logger.log("Napravelo: " .. (napravelo and ' ON' or 'OFF'))
  end)

  hs.hotkey.bind(mods.pos, profile['work'], function()
    work = not work
    logger.log("Work: " .. (work and ' ON' or 'OFF'))
  end)

  hs.hotkey.bind(mods.pos, profile['follow'], function()
    follow = screen.setFollowMode(not follow)
    logger.log("Follow: " .. (follow and ' ON' or 'OFF'))
  end)

  for key, target in pairs(apps) do
    hs.hotkey.bind(mods.hyper, key, function()
      if not napravelo and target.napravelo then return end
      if not work and target.work then return end
      if not distractors and target.distractor then return end
      if (target.handler) then
        target.handler()
      else
        hs.application.launchOrFocus(target.name)
        hs.timer.doAfter(0.1, function() screen.centerOn(hs.window.focusedWindow()) end)
      end
    end)
  end

  return screen
end

return M
