local M = {}

local cfg = {
  profiles = {},
  name = "Google Chrome",
  path = "/Library/Application Support/Google/Chrome/Local State",
  openCmd = "/usr/bin/open",
}

function M.setup(opts)
  if opts then
    if opts.profiles then cfg.profiles = opts.profiles end
    if opts.name then cfg.name = opts.name end
    if opts.openCmd then cfg.openCmd = opts.openCmd end
  end
end

function M.handleFocus(profileKey)
  return function()
    local profileDir = cfg.profiles[profileKey]
    if not profileDir then
      hs.alert.closeAll()
      hs.alert.show("Chrome: unknown profile '" .. tostring(profileKey) .. "'")
      profileDir = 'Default'
    end

    local statePath = os.getenv("HOME") .. cfg.path
    local localState = hs.json.read(statePath)
    local friendlyName
    if localState and localState.profile and localState.profile.info_cache and localState.profile.info_cache[profileDir] then
      friendlyName = localState.profile.info_cache[profileDir].name
    end

    local windows = hs.window.filter.new(false):setAppFilter(cfg.name):getWindows()
    for _, win in ipairs(windows) do
      local title = win:title()
      if friendlyName and title:find(friendlyName, 1, true) then
        win:focus()
        return
      end
    end

    hs.task.new(cfg.openCmd, nil, {
      "-na", cfg.name,
      "--args", "--profile-directory=" .. profileDir
    }):start()
  end
end

return M
