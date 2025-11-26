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
    quiet = {
      order = 1,
      key = 'q',
      label = 'WARTOSC',
      active = false,
      warn = {
        image = logger.images.terry2,
        text = {
          'AN IDIOT admires COMPLEXITY\nA GENIUS admires SIMPLICITY',
          'This is Voodoo, but...\nIS THIS TOO MUCH?!',
          'Is this TOO MUCH Voodoo?',
          'Is this DIVINE INTELLECT?',
        }
      }
    },
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
    ["i"] = { name = "Google Chrome: Personal", handler = chrome.handleFocus('personal') },

    ["o"] = { name = "Google Chrome: Napravelo", handler = chrome.handleFocus('napravelo'), napravelo = true },

    ["f"] = { name = "Figma", napravelo = true },
    ["t"] = { name = "Linear", napravelo = true },
    ["s"] = { name = "Discord", napravelo = true },

    ["p"] = { name = "Visual Studio Code", work = true },
    ["'"] = { name = "iTerm", work = true },

    ["e"] = { name = "Docker Desktop", napravelo_infra = true },
    ["d"] = { name = "DBeaver", napravelo_dbeaver = true },

    ["x"] = { name = "Messenger", quiet = false },
    ["v"] = { name = "Telegram", quiet = false },

    ["m"] = { name = "Spotify", },
    ["g"] = { name = "Finder", },
    ["\\"] = { name = "1Password", }
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

hs.hotkey.bind(config.keyboard_mods.pos, "]", function() screen.to(0) end)
hs.hotkey.bind(config.keyboard_mods.pos, "[", function() screen.to(1, { [2] = 0, [3] = 1 }) end)
hs.hotkey.bind(config.keyboard_mods.pos, "'", function() screen.to(1, { [2] = 1, [3] = 2 }) end)


hs.hotkey.bind(config.keyboard_mods.pos, "-", function() screen.scaleX(-0.1) end)
hs.hotkey.bind(config.keyboard_mods.pos, "=", function() screen.scaleX(0.1) end)

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

hs.hotkey.bind(config.keyboard_mods.hyper, "f1", function() hs.reload() end)
hs.alert.show("Hammerspoon Reloaded")
