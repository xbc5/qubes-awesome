local awful = require("awful")
local x = {
  xprop = require("x.xprop"),
  notify = require("x.notify"),
  cmd = require("x.cmd"),
}

local Scratch = {}
local MetaScratch = { __index = Scratch }

-- Create a new Scratch instance
-- @param launcher A function that accepts a callback with a single arg:
--  launcher(fn(ok)): it calls fn after launch success or fail, as indicated by ok.
-- @param shutown A boolean or a function -- non-nil means that the qube stops when
--   app closes. If it's a function then: fn(ok, stdout, stderr)
function Scratch.new(c, kind, shutdown)
  local self = setmetatable({}, MetaScratch)
  self.shutdown = shutdown

  c.floating = true
  c.ontop = true
  c.above = true
  c.sticky = true
  c.skip_taskbar = true
  c.hidden = false
  c.screen = awful.screen.focused()

  if kind == "modal" then
    c.maximized = true
  elseif kind == "dev_console" then
    awful.placement.top(c)
    awful.placement.maximize_horizontally(c)
  else
    error("unknown scratch kind: " .. kind)
  end

  self.c = c

  self:focus()
  return self
end

-- Focus the client.
-- @return nil
function Scratch:focus()
  client.focus = self.c
  self.c:raise()
end

-- Hide a client.
-- @return nil
function Scratch:hide()
  self.c.hidden = true
end

-- Show and focus a client.
-- @return nil
function Scratch:show()
  self.c.hidden = false
  self:focus()
end

-- Close the client. Sometimes you want to perform some action
-- when closing -- e.g. shutdown the qube.
-- @return nil
function Scratch:close()
  if self.shutdown then
    x.cmd.shutown(self.c.qubes_vmname, self.shutdown)
  end
end

-- Toggle the visibility of the client, and focus it if it's visible.
-- return nil
function Scratch:toggle()
  self.c.hidden = not self.c.hidden
  if not self.c.hidden then self:focus() end
end

local Manager = {}
local MetaManager = { __index = Manager }

-- Manages clients by rejecting duplicates, tracking those active,
-- ensuring only one within a group (kind) is visible at a time. This
-- is an unenforced singleton that manages dumb Scratch clients.
function Manager.new()
  local self = setmetatable({}, MetaManager)
  -- These are caches to track active clients; don't touch.
  self.modal = {}
  self.dev_console = {}

  -- Why do we have kinds?:
  --   The rules for each kind are different. Each is a group,
  --   where only one in a group is visible at a time. Also,
  --   each kind may have different client properties -- e.g.
  --   maximised, or centred. If you clients to act differently
  --   as a group, then you need a new kind.
  self.kind = {
    modal = "modal", -- e.g. centred, near maximised
    dev_console = "dev_console", -- e.g. a drop-down terminal (half of the screen)
  }

  return self -- self (huehue)
end

-- Determine if thee is a Scratch client for the
-- specific key and kind.
-- @param key The cache key -- typcially the X.class name.
-- @param kind The group to which the Scratch belongs.
-- @return boolean: true if it exists; false otherwise.
function Manager:has(key, kind)
  return self[kind][key] ~= nil
end

-- Get a specific Scratch client,
-- specific key and kind.
-- @param key The cache key -- typcially the X.class name.
-- @param kind The group to which the Scratch belongs.
-- @return a Scratch client.
function Manager:get(key, kind)
  return self[kind][key]
end

-- Delete a specific Scratch client.
-- specific key and kind.
-- @param key The cache key -- typcially the X.class name.
-- @param kind The group to which the Scratch belongs.
-- @return nil.
function Manager:del(key, kind)
  self[kind][key] = nil
end

-- Hide everything except one item.
-- @param kind The scratch kind.
-- @param key The client to skip; can be nil.
-- @return nil.
function Manager:hide_all_except(kind, key)
  for k, item in pairs(self[kind]) do
    if k ~= key then item:hide() end -- everything else
  end
end

-- Hide everything. Useful during startup to prevent
-- refreshes from displaying all hidden clients.
-- @return nil
function Manager:hide_all()
  for _, kind in pairs(self.kind) do
    for _, _client in pairs(self[kind]) do
      _client:hide()
    end
  end
end


-- Launch a client if it doesn't exist; toggle its visibility
-- if it does.
-- @param key Typically this is the class name, or class prop from xprop module.
-- @param pat A pattern to match the client -- typcially this is some form of pattern
--  derived from the X.class. This is typically the class_p property from the xprop module.
-- @param kind The scratch kind.
-- @param launcher A function for starting the client:
--   e.g. function(fn) ... end
--   When the command completes, it should call fn(ok), where ok
--   is exit_code == 0. In other words: the function that you pass in
--   accepts a callback with an 'ok' argument.
-- @param shutown A boolean or a function -- non-nil means that the qube stops when
--   app closes. If it's a function then: fn(ok, stdout, stderr)
-- @return nil
function Manager:toggle(key, pat, kind, launcher, shutdown)
  -- Client exists, use it (toggle it).
  if self:has(key, kind) then
    self:hide_all_except(kind, key)
    self[kind][key]:toggle()
    return
  end

  -- Client doesn't exist: start it, then track it

  -- stop tracking the client after it's closed
  local function delete_if_matches(c)
    if string.match(c.class, pat) then
      client.disconnect_signal("unmanage", delete_if_matches)
      -- don't bother waiting, if it fails it fails, the client is gone from Awesome anyway
      local cl = self:get(key, kind)
      if cl then
        cl:close()
        self:del(key, kind)
      end
    end
  end
  client.connect_signal("unmanage", delete_if_matches)

  -- track the client when one (with a matching class) is opened
  local function track_if_matches(c)
    if string.match(c.class, pat) then
      client.disconnect_signal("manage", track_if_matches)
      self:track(c, key, kind, shutdown)
    end
  end
  client.connect_signal("manage", track_if_matches) -- to get out-of-band clients

  -- launch it, and hide all others of the same kind if it launches successfully
  launcher(function(ok)
    if ok then
      self:hide_all_except(kind, key)
    else
      -- client failed, we no longer need these
      client.disconnect_signal("manage", track_if_matches)
      client.disconnect_signal("unmanage", delete_if_matches)
    end
  end)
end

-- Tracking a client means to cache and manage it. You can track multiple of each kind, as
-- long as their key differs (i.e. their X.class name). This means multiple modals; or multiple
-- dev-consoles. If that key already exists, it kills that client and returns false.
-- @param c An Awesome client.
-- @param key The cache key (typically the X.class name).
-- @param kind The group to which the client belongs.
-- @param shutown A boolean or a function -- non-nil means that the qube stops when
--   app closes. If it's a function then: fn(ok, stdout, stderr)
-- @return false if the exact client already exists; true otherwise.
function Manager:track(c, key, kind, shutdown)
  -- track if not tracking; otherwise kill
  if not self:has(key, kind) then
    self[kind][key] = Scratch.new(c, kind, shutdown) -- TODO: use inheritance
    return true
  end
  c:kill()
  return false
end

function Manager:validate_spec(spec)
  if spec.class == nil then error("class not set for xprop spec") end
  if spec.class_p == nil then error("class_p not set for xprop spec") end
  return spec
end

-- Start a developer console.
-- @param domain The name of the domain to run it on: e.g. dom0, foo.
-- @return nil
function Manager:toggle_dev_console(domain)
  local spec = self:validate_spec(x.xprop.dev_console)
  -- we use domain:app for key so that we can toggle between
  -- consoles on different domains.
  self:toggle(
    spec.full_class(domain), -- provides domain:app
    spec.class_p,
    self.kind.dev_console,
    function(cb)
      x.cmd.dev_console(domain, cb)
    end)
end

-- Start the notes application.
-- @return nil
function Manager:toggle_notes()
  local spec = self:validate_spec(x.xprop.notes)
  self:toggle(
    spec.class,
    spec.class_p,
    self.kind.modal,
    x.cmd.notes,
    true)
end

-- Start the matrix client.
-- @return nil
function Manager:toggle_matrix()
  local spec = self:validate_spec(x.xprop.matrix_c)
  self:toggle(
    spec.class,
    spec.class_p,
    self.kind.modal,
    x.cmd.matrix,
    true)
end

local manager = Manager.new()

awesome.connect_signal("startup", function()
  manager:hide_all()
end)

return manager
