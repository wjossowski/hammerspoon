local M = {}

M.config = {
  profiles = {
    __IGNOREME__ = "Default",
  },
  name = "Google Chrome",
  openCmd = "/usr/bin/open",
}

function M.setup(opts)
  if opts then
    if opts.profiles then M.config.profiles = opts.profiles end
    if opts.name then M.config.name = opts.name end
    if opts.openCmd then M.config.openCmd = opts.openCmd end
  end
end

function M.focus(profileKey)
  local cfg = M.config
  local profileDir = cfg.profiles[profileKey]
  if not profileDir then
    hs.alert.show("Chrome: unknown profile '" .. tostring(profileKey) .. "'")
    return
  end

  -- local app = hs.application.find(cfg.name)
  -- if app and app:isFrontmost() then
  --   return
  -- end

  local windows = hs.window.filter.new(false):setAppFilter(cfg.name):getWindows()
  for _, win in ipairs(windows) do
    local title = win:title()
    if title:find(profileDir, 1, true) then
      win:focus()
      return
    end
  end

  hs.task.new(cfg.openCmd, nil, {
    "-na", cfg.name,
    "--args", "--profile-directory=" .. profileDir
  }):start()
end

return M
