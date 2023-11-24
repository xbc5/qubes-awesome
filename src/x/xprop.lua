-- Join a qube name and an app to form an X class prop.
-- @return A string: e.g. qube:app-name
function join(qube, app)
  return qube .. ":" .. app
end


local M = {
  -- qubes
  daily = {
    class_p = "^daily",
  },
  dev = {
    class_p = "^dev",
  },
  dev_s = {
    class_p = "^dev[-]s", -- '-' does not match on its own
  },

  -- apps
  dev_console = {
    class   =    "developer-console",
    class_p = ".+:developer[-]console$",
    full_class = function(domain) return join(domain, "developer-console") end,
  },
  ide = {
    class_p = "ide$",
  },
  librewolf = {
    class_p = "librewolf[-].+$"  -- librewolf includes the profile name
  },
  matrix_c = {
    class   = "matrix:librewolf-default",
    class_p = "^matrix:librewolf[-]default$",
  },
  notes = {
    class   = "notes:Emacs",
    class_p = "^notes:Emacs$",
  },
  rofi = {
    class_p = "[rR]ofi$", -- [:^][rR]ofi$ doesn't match "rofi" (i.e. dom0)
  },
}

-- A pattern rule that matches the developer console for any domain.
-- @return An Awesome rule: { class = {...} }
function M.dev_console_rulep()
  local c = M.dev_console.class_p
  return { class = { c } }
end


-- A rule that matches all browsers
-- @return An Awesome rule: { class = {...} }
function M.browser_rule(qube)
  local c = M.librewolf.class_p
  return { class = { join(qube, c) } }
end

-- A rule that matches the IDE
-- @return An Awesome rule: { class = {...} }
function M.ide_rule(qube)
  local c = M.ide.class_p
  return { class = { join(qube, c) } }
end

return M
