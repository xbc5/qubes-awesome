-- Join a domain name and an app to form an X class prop.
-- @return domain A string: e.g. qube:app-name
function join(domain, app)
  if domain == "dom0" or domain == nil then
    return app -- dom0 classes are just the app name
  else
    return domain .. ":" .. app
  end
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
    class_p = "developer[-]console$",
    full_class = function(domain) return join(domain, "developer-console") end,
  },
  ide = {
    class_p = "ide$",
  },
  email_client = {
    class = "email:client",
    class_p = "^email:client$",
  },
  email = {
    class_p = "^email:.+$",
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

-- A pattern rule that matches modals.
-- @return An Awesome rule: { class = {...} }
function M.modal_rulep()
  return { class = { M.matrix_c.class_p, M.notes.class_p } }
end

-- A pattern rule that matches scratch clients.
-- @return An Awesome rule: { class = {...} }
function M.scratch_rulep()
  return { class = { M.matrix_c.class_p, M.notes.class_p, M.dev_console.class_p } }
end

-- A pattern rule that matches the email client.
-- @return An Awesome rule: { class = {...} }
function M.email_client_rulep()
  return { class = { M.email_client.class_p } }
end

-- A pattern rule that matches all clients for the email domain.
-- @return An Awesome rule: { class = {...} }
function M.email_rulep()
  return { class = { M.email.class_p } }
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
