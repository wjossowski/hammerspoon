local screen = require('modules.screen')
local apps = require("modules.apps")
local chrome = require("modules.chrome")
local logger = require("modules.logger")

chrome.setup({
  profiles = {
    personal = 'Default',
    napravelo = 'Profile 1',
  }
})

local config = {
  profiles = {
    quiet = { order = 1, key = 'q', label = 'WARTOSC', active = false, warn = { text = 'BAMBUSIE JEBANY', image = logger.images.bambus } },
    work = { order = 2, key = 'w', label = 'Work', active = true, off = { 'napravelo' } },
    napravelo = { order = 3, key = 'e', label = 'Napravelo', active = true, on = { 'work' }, off = { 'napravelo_infra', 'napravelo_dbeaver' } },
    napravelo_infra = { order = 4, key = 's', label = 'Napravelo:Infra', active = false, on = { 'napravelo' } },
    napravelo_dbeaver = { order = 5, key = 'd', label = 'Napravelo:DBeaver', active = false, on = { 'napravelo' } },
  },
  keyboard_mods = {
    hyper = { "ctrl", "alt", "cmd", "shift" },
    pos   = { "cmd", "ctrl", "shift" }
  },
  chrome_profiles = {
    personal = 'Default',
    napravelo = 'Profile 1',
  },
  apps = {
    ["i"] = { name = "Google Chrome", napravelo = false },
    ["u"] = { name = "Google Chrome: Personal", handler = chrome.handleFocus('personal') },
    ["o"] = { name = "Google Chrome: Napravelo", handler = chrome.handleFocus('napravelo'), napravelo = true },

    ["f"] = { name = "Figma", napravelo = true },
    ["t"] = { name = "Linear", napravelo = true },
    ["d"] = { name = "DBeaver", napravelo_dbeaver = true },
    ["]"] = { name = "iTerm", work = true },
    ["p"] = { name = "Visual Studio Code", work = true },
    ["e"] = { name = "Docker Desktop", napravelo_infra = true },

    ["s"] = { name = "Discord", napravelo = true },
    ["x"] = { name = "Messenger", quiet = false },
    ["v"] = { name = "Telegram", quiet = false },

    ["m"] = { name = "Spotify", },
    ["g"] = { name = "Finder", },
    ["1"] = { name = "1Password", }
  }
}

local positions = {
  ["i"] = { 0, 0, 1, 0.5 },       -- top-half
  [","] = { 0, 0.5, 1, 0.5 },     -- bottom-half
  ["j"] = { 0, 0, 0.5, 1 },       -- left-half
  ["l"] = { 0.5, 0, 0.5, 1 },     -- right-half
  ["u"] = { 0, 0, 0.5, 0.5 },     -- top-left
  ["o"] = { 0.5, 0, 0.5, 0.5 },   -- top-right
  ["m"] = { 0, 0.5, 0.5, 0.5 },   -- bottom-left
  ["."] = { 0.5, 0.5, 0.5, 0.5 }, -- bottom-right
  ["k"] = { 0, 0, 1, 1 },         -- maximized
}

apps.setup(config)

for key, posVals in pairs(positions) do
  hs.hotkey.bind(config.keyboard_mods.pos, key, function() screen.move(table.unpack(posVals)) end)
end

hs.hotkey.bind(config.keyboard_mods.pos, "f12", function() screen.to(0) end)
hs.hotkey.bind(config.keyboard_mods.pos, "f11", function() screen.to(1, { [2] = 1, [3] = 1 }) end)
hs.hotkey.bind(config.keyboard_mods.pos, "f10", function() screen.to(1, { [2] = 1, [3] = 2 }) end)

hs.hotkey.bind(config.keyboard_mods.pos, "-", function() screen.previous() end)
hs.hotkey.bind(config.keyboard_mods.pos, "=", function() screen.next() end)

hs.hotkey.bind(config.keyboard_mods.pos, "[", function() screen.scaleX(-0.1) end)
hs.hotkey.bind(config.keyboard_mods.pos, "]", function() screen.scaleX(0.1) end)

hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  local flags = event:getFlags()
  local keyCode = event:getKeyCode()
  if flags.cmd and keyCode == 50 then
    hs.timer.doAfter(0.1, function()
      screen.centerOn(hs.window.focusedWindow())
    end)
    return false -- przepuść dalej do systemu
  end
  return false
end):start()

hs.hotkey.bind(config.keyboard_mods.hyper, "f12", function() hs.reload() end)
hs.alert.show("Hammerspoon Reloaded")
