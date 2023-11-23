local awful = require("awful")
local x = {
  xprop = require("x.xprop"),
  notify = require("x.notify"),
  cmd = require("x.cmd"),
}

local notes = x.xprop.notes
local dev_console = x.xprop.dev_console
local matrixc = x.xprop.matrix_c

local Scratch = {}
local MetaScratch = { __index = Scratch }

-- Create a new Scratch instance
-- @param launcher A function that accepts a callback with a single arg:
--  launcher(fn(ok)): it calls fn after launch success or fail, as indicated by ok.
function Scratch.new(launcher) -- a . means "don't use"
  local self = setmetatable({}, MetaScratch)
  self.c = nil
  self._launch = launcher
  self.launched = false
  self.locked = false
  return self
end

-- Add a client only if it doesn't exist. Use this in a manage signal.
-- If there is already a client, it will kill the new client. The toggle
-- method is careful to not enable
-- @return boolean: false if the client already exists; true otherwise.
function Scratch:add(c)
  if self.c ~= nil then
    x.notify.client_error("Client exists: " .. c.class)
    c:kill()
    return false
  end

  c.floating = true
  c.ontop = true
  c.above = true
  c.sticky = true
  c.skip_taskbar = true
  c.hidden = false
  c.screen = awful.screen.focused()
  self.c = c

  self:focus()

  return true
end

-- Focus the client.
function Scratch:focus()
  client.focus = self.c
  self.c:raise()
end

function Scratch:hide()
  self.c.hidden = true
end

function Scratch:show()
  self.c.hidden = false
  self:focus()
end

function Scratch:toggle()
  self.c.hidden = not self.c.hidden
  if not self.c.hidden then self:focus() end
end

local Manager = {}
local MetaManager = { __index = Manager }

function Manager.new()
  local self = setmetatable({}, MetaManager)
  self.modal = {}
  self.dev_console = {}
  self.kinds = {
    [notes.class] = "modal",
    [matrixc.class] = "modal",
    [dev_console.class] = "dev_console",
  }
  return self
end

function Manager:has(key, kind)
  return self[kind][key] ~= nil
end

function Manager:get(key, kind)
  return self[kind][key]
end

-- Hide everything except one item.
-- @param kind The scratch kind.
-- @param except_key The client to skip; can be nil.
function Manager:hide_all_except(kind, key)
  for k, item in pairs(self[kind]) do
    if k ~= key then item:hide() end -- everything else
  end
end

function Manager:spawn(key, kind, launch)
  -- if exists toggle; otherwise launch
  if self:has(key, kind) then
    self:hide_all_except(kind, key)
    self[kind][key]:toggle()
  else
    launch(function(ok)
      self.locked[kind][key]
      if ok then self:hide_all_except(kind, key) end
    end)
  end
end

-- Tracking a client means to cache and manage it. You can track multiple of each kind, as
-- long as their key differs (i.e. their X.class name). This means multiple modals; or multiple
-- dev-consoles. If that key already exists, it kills that client and returns false.
-- @return return false if the exact client already exists; true otherwise.
function Manager:track(c)
  -- track if not tracking; otherwise kill
  local kind = self.kinds[c.class]
  local key = c.class
  if not self:has(key, kind) then
    self[kind][key] = c
    return true
  end
  c:kill()
  return false
end

function Manager:toggle_dev_console(domain)
  local key = dev_console.class
  local kind = self.kinds[key]
  self:spawn(key, kind, function(cb) x.cmd.dev_console(domain, cb) end)
end

function Manager:toggle_notes()
  local key = notes.class
  local kind = self.kinds[key]
  self:spawn(key, kind, x.cmd.notes)
end

function Manager:toggle_matrix()
  local key = matrixc.class
  local kind = self.kinds[key]
  self:spawn(key, kind, x.cmd.matrix)
end

local M = {
  clients = {}, -- a cache to hold active clients for easy searching
  xrole = { modal = "scratch:modal", dev_console = "scratch:dev-console" },
  rules = {
    modals = { class = { notes.class, matrixc.class } },
    dev_console = x.xprop.dev_console_rulep(), -- {class={pattern}}
  },
}

function M.has(key)
  return M.clients[key] ~= nil
end

function M.get(key)
  return M.clients[key]
end

-- Add a client to the cache. Errors if it already exists.
-- @param c An Awesome client.
function M.add(c)
  if M.has(c.class) then
    x.notify.client_error(c.class .. " already exists")
    return
  end
  M.clients[c.class] = c
end

-- Add a client to the cache.
-- @param c An Awesome client.
function M.del(c)
  M.clients[c.class] = nil
end

-- Provide the class name of the window you wish to see.
-- This will either use the cached client or start a new
-- one if it doesn exist.
-- @param key The cache key -- typcially the class name of the client.
-- @param fn The [optional] function that starts the command, client or application --
--  async or not, it doesn't matter: fn() (no args).
function M.toggle(key, fn)
  local c = M.get(key)
  if c ~= nil then
    c.hidden = not c.hidden
    if not c.hidden then
      client.focus = c
      c:raise()
    end
  elseif fn then
    fn()
  end
end

-- Toggle the notes scratch.
-- @param fn The [optional] function that starts the command, client or application --
--  async or not, it doesn't matter: fn() (no args).
function M.toggle_notes(fn)
  M.toggle(notes.class, fn)
end

-- Toggle the matrix scratch.
-- @param fn The [optional] function that starts the command, client or application --
--  async or not, it doesn't matter: fn() (no args).
function M.toggle_matrix(fn)
  M.toggle(matrixc.class, fn)
end

function M.toggle_dev_console(domain, fn)
  M.toggle(dev_console.class, fn)
end

function M.create(c)
  c.floating = true
  c.ontop = true
  c.above = true
  c.sticky = true
  c.skip_taskbar = true
  c.hidden = false -- on creation
  c.screen = awful.screen.focused()
  client.focus = c
  c:raise()
  M.add(c)
end

client.connect_signal("manage", function(c)
  if awful.rules.match_any(c, M.rules.modals) then
    c.xrole = M.xrole.modal
    c.maximized = true
    M.create(c)
  elseif awful.rules.match_any(c, M.rules.dev_console) then
    x.notify.test("add: " .. c.qubes_vmname)
    c.xrole = M.xrole.dev_console
    awful.placement.top(c)
    awful.placement.maximize_horizontally(c)
    M.create(c)
  end
end)

client.connect_signal("unmanage", function(c)
  if c.xrole == M.xrole.modal or c.xrole == M.xrole.dev_console then
    x.notify.test("delete: " .. c.xrole)
    M.del(c)
  end
end)

return M
