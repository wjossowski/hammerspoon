local logger = require("modules.logger")
local screen = require("modules.screen")

local M = { state = nil }

local log = hs.logger.new('apps', 'debug')

local function logState(time)
  local lines = {}

  -- Sortowanie state
  local sortedState = (function(t)
    local arr = {}
    for _, x in pairs(t) do arr[#arr + 1] = x end
    table.sort(arr, function(a, b) return a.order < b.order end)
    return arr
  end)(M.state)

  -- Znajdź najdłuższą labelkę (z kluczem)
  local maxLength = 0
  for _, row in ipairs(sortedState) do
    local fullLabel = string.format('[%s] %s', row.key, row.label)
    if #fullLabel > maxLength then
      maxLength = #fullLabel
    end
  end

  -- Dodaj 1 znak spacingu
  local spacing = maxLength + 1

  for _, row in ipairs(sortedState) do
    local status = row.active and "ON" or "OFF"
    local fullLabel = string.format('[%s] %s', row.key, row.label)
    local line = string.format("%-" .. spacing .. "s | %-3s", fullLabel, status)
    table.insert(lines, line)
  end

  logger.log(table.concat(lines, "\n"), time)
end

local function toggle(key, newState)
  local profile = M.state[key]
  if profile == nil then return end
  local toggler = (newState == true and profile.on)
      or (newState == false and profile.off)
      or {}
  for _, child in pairs(toggler) do
    toggle(child, newState)
  end
  profile.active = newState
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

    if profile.off ~= nil then
      M.state[key].off = profile.off
    end

    if profile.on ~= nil then
      M.state[key].on = profile.on
    end

    hs.hotkey.bind(config.keyboard_mods.pos, profile.key, function()
      toggle(key, not M.state[key].active)
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
          if profile.warn ~= nil then return logger.logImage(profile.warn.text, profile.warn.image) end
          return
        elseif profile.active and app[profileKey] == true then
          run = true
        elseif not profile.active and app[profileKey] == false then
          run = true
        elseif not profile.active and app[profileKey] == true then
          table.insert(avain, profile.label)
        end
      end


      if not defaulted and not run then
        return logger.log(app.name .. ' available in ' .. table.concat(avain, ', '), 0.5)
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
