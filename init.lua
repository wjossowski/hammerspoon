local screen = require('modules.screen')
local apps = require("modules.apps")
local chrome = require("modules.chrome")

local config = {
  profiles = {
    silent = { key = 's', label = 'Distractors' },
    work = { key = 'w', label = 'Work' },
    napravelo = { key = 'n', label = 'Work:Napravelo' }
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
    -- Work
    ["f"] = { name = "Figma", work = true, napravelo = true },
    ["t"] = { name = "Linear", work = true, napravelo = true },
    ["d"] = { name = "DBeaver", work = true, napravelo = true },
    ["]"] = { name = "iTerm", work = true },
    ["p"] = { name = "Visual Studio Code", work = true },
    ["e"] = { name = "Docker Desktop", work = true },

    -- Browsing
    ["i"] = { name = "Google Chrome", },
    ["u"] = { handler = chrome.handleFocus('personal') },
    ["o"] = { handler = chrome.handleFocus('napravelo') },

    -- Chats
    ["s"] = { name = "Discord", napravelo = true },
    ["x"] = { name = "Messenger", distractor = true },
    ["v"] = { name = "Telegram" },

    -- Misc
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

chrome.setup({
  profiles = {
    personal = 'Default',
    napravelo = 'Profile 1',
  }
})

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
hs.alert.show("Hammerspoon Config Reloaded")
