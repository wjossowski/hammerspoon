local logger = require("modules.logger")
local screen = require("modules.screen")

local M = { state = nil }

local function validate()
  if not M.state then
    error("apps.setup() must be called before use")
  end
end

local function logState()
  validate()
  local msg = "SETUP:"
  for _, val in pairs(M.state) do
    msg = msg .. "\n  " .. val.label
        .. " (" .. val.key .. ")" .. " : " .. (val.active and "on" or "off")
  end
  logger.log(msg)
end

function M.setup(config)
  M.state = {}
  for key, profile in pairs(config.profiles) do
    M.state[key] = {
      label = profile.label,
      key = profile.key,
      active = profile.active
    }
  end

  hs.hotkey.bind(config.keyboard_mods.pos, "1", logState)

  for key, profile in pairs(config.profiles) do
    hs.hotkey.bind(config.keyboard_mods.pos, profile.key, function()
      validate()
      M.state[key].active = not M.state[key].active
      logger.log(profile.label .. ": " .. (M.state[key] and " ON" or "OFF"))
    end)
  end

  for hotkey, app in pairs(config.apps) do
    hs.hotkey.bind(config.keyboard_mods.hyper, hotkey, function()
      validate()

      local run = false

      for profileKey, profile in pairs(M.state) do
        if profile.active and app[profileKey] == false then
          run = false
        elseif profile.active and app[profileKey] == true then
          run = true
        elseif not profile.active and app[profileKey] == false then
          run = true
        end
      end


      if not run then return end

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
