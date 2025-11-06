local logger = require("modules.logger")
local screen = require("modules.screen")

local M = { state = nil }

local function logState(time)
  local msg = "SETUP:"
  for _, v in ipairs((function(t)
    local arr = {}
    for _, x in pairs(t) do arr[#arr + 1] = x end
    table.sort(arr, function(a, b) return a.order < b.order end)
    return arr
  end)(M.state)) do
    msg = msg .. "\n  " .. v.label .. " (" .. v.key .. "): " .. (v.active and "1" or "0")
  end

  logger.log(msg, time)
end

function M.setup(config)
  M.state = {}

  hs.hotkey.bind(config.keyboard_mods.pos, "1", function() logState(4) end)

  for key, profile in pairs(config.profiles) do
    M.state[key] = {
      order = profile.order,
      label = profile.label,
      key = profile.key,
      active = profile.active,
      warn = profile.warn
    }

    hs.hotkey.bind(config.keyboard_mods.pos, profile.key, function()
      M.state[key].active = not M.state[key].active
      logState()
    end)
  end


  for hotkey, app in pairs(config.apps) do
    hs.hotkey.bind(config.keyboard_mods.hyper, hotkey, function()
      local defaulted = true
      local run = false
      local avain = {}

      for profileKey, profile in pairs(M.state) do
        if app[profileKey] ~= nil then defaulted = false end
        if profile.active and app[profileKey] == false then
          if (profile.warn ~= nil) then
            logger.log(profile.warn, 0.5)
          else
            logger.log(app.name .. ' not available in ' .. profile.label .. '(' .. profile.key .. ')' .. ' mode.', 0.5)
          end
          return
        elseif profile.active and app[profileKey] == true then
          run = true
        elseif not profile.active and app[profileKey] == false then
          run = true
        else
          table.insert(avain, profile)
        end
      end


      if not defaulted and not run then
        logger.log(app.name .. ' available in ', 0.5)
        return
      end

      if app.handler then
        app.handler()
      elseif app.name then
        hs.application.launchOrFocus(app.name)
        hs.timer.doAfter(0.1, function()
          local win = hs.window.focusedWindow()
          if win then screen.centerOn(win) end
        end)
      end
    end)
  end
end

return M
