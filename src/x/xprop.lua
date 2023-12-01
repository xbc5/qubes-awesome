-- Join a domain name and an app to form an X class prop.
-- @return domain A string: e.g. qube:app-name
local function join(domain, app)
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
    class   = "dev",
    class_p = "^dev",
  },
  dev_s = {
    class = "dev-s",
    class_p = "^dev[-]s", -- '-' does not match on its own
  },
  fin = {
    class_p = "^fin",
  },
  notes = {
    class_p = "^notes",
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
  notes_c = {
    class   = "notes:Emacs",
    class_p = "^notes:Emacs$",
  },
  rofi = {
    class_p = "[rR]ofi$", -- [:^][rR]ofi$ doesn't match "rofi" (i.e. dom0)
  },

  -- terminals
  kitty = {
    class_p = "kitty",
  },
  xterm = {
    class_p = "xterm",
  },
}

function M.terminals_class(domain)
  return {join(domain, M.kitty.class_p), join(domain, M.xterm.class_p)}
end

-- A pattern rule that matches the developer console for any domain.
-- @return An Awesome rule: { class = {...} }
function M.dev_console_rulep()
  local c = M.dev_console.class_p
  return { class = { c } }
end

-- A pattern rule that matches modals.
-- @return An Awesome rule: { class = {...} }
function M.modal_rulep()
  return { class = { M.matrix_c.class_p } }
end

-- A pattern rule that matches scratch clients.
-- @return An Awesome rule: { class = {...} }
function M.scratch_rulep()
  return { class = { M.matrix_c.class_p, M.dev_console.class_p } }
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

-- A pattern rule that matches the fin domain
-- @return An Awesome rule: { class = {...} }
function M.fin_rulep()
  return { class = { M.fin.class_p .. ":.+$" } }
end

-- A pattern rule that matches the notes client.
-- @return An Awesome rule: { class = {...} }
function M.notes_client_rulep()
  return { class = { M.notes_c.class_p } }
end

-- A pattern rule that matches the notes domain.
-- @return An Awesome rule: { class = {...} }
function M.notes_domain_rulep()
  return { class = { M.notes.class_p .. ":.+$" } }
end

-- A pattern rule that matches the primary fin domain
-- @return An Awesome rule: { class = {...} }
function M.fin_client_rulep()
  return { class = { join(M.fin.class_p, M.librewolf.class_p) } }
end

function M.daily_client_rulep()
  return { class = { join(M.daily.class_p, M.librewolf.class_p) } }
end

function M.daily_domain_rulep()
  return { class = { join(M.daily.class_p, ".+$") } }
end

function M.dev_e_client_rulep()
  return { class = { join(M.dev.class_p, M.ide.class_p) } }
end

function M.dev_b_client_rulep()
  return { class = { join(M.dev.class_p, M.librewolf.class_p) } }
end

function M.dev_t_client_rulep()
  return { class = M.terminals_class(M.dev.class) }
end

function M.dev_s_domain_rulep()
  return { class = { M.dev_s.class_p .. ":.+$" } }
end

function M.dev_s_client_rulep()
  return { class = { join(M.dev_s.class_p, M.ide.class_p) } }
end

function M.dev_domain_rulep()
  return { class = { join(M.dev.class_p, ".+$") } }
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

local Prop = {}
Prop.__index = Prop

-- @param app_p [optional] specify a more precise app
--  pattern -- e.g. instead of librewolf-default (which
--  is the app name), you can specify librewolf-.+.
--  Use it by passing true into app(): `:app(true)`.
function Prop.new(domain, app, app_p)
  local self = setmetatable({}, Prop)

  self._domain = domain or ""
  self._app = app
  if not app_p then
    self._app_p = app .. "$"
  else
    self._app_p = app_p
  end

  self._build = {}

  return self
end

function Prop:pat()
  self._pat = true
  return self
end

function Prop:domain(domain)
  local d = domain or self._domain
  if d ~= "dom0" and d ~= "" and d ~= nil then
    self._build.domain = d
  else
    self._dom0 = true
  end
  return self
end

-- @param use_pat Use `app_p` instead of `app`.
function Prop:app(use_pat)
  if self._pat and use_pat then
    self._build.app = self._app_p
  else
    self._build.app = self._app
  end
  return self
end

function Prop:build(rule)
  local r = ""

  -- have domain, not dom0
  if not self._dom0 and self._build.domain then
    r = self._build.domain

    if self._build.app then
      r = self._build.domain .. ":" .. self._build.app
    elseif self._pat then
      r = r .. ":.+$"
    end
  else
    -- is dom0
    if self._build.app then
      r = self._build.app
    end
  end

  if self._pat then
    -- replace chars that confuse the pattern parser
    r = "^" .. r:gsub("-", "[-]") .. "$"
  end

  self._cache = r

  if rule then return { class = { r } } else return r end
end

function Prop:get_cached(rule)
  if not (self._cache) then error("no cached value") end
  if rule then return { class = { self._cache } } else return self._cache end
end

M.xnotes = Prop.new("notes", "Emacs")

return M
