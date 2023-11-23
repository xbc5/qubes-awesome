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
function Scratch.new(c, kind)
  local self = setmetatable({}, MetaScratch)
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

function Manager:del(key, kind)
  self[kind][key] = nil
end

-- Hide everything except one item.
-- @param kind The scratch kind.
-- @param except_key The client to skip; can be nil.
function Manager:hide_all_except(kind, key)
  for k, item in pairs(self[kind]) do
    if k ~= key then item:hide() end -- everything else
  end
end


function Manager:toggle(key, kind, launch)
  -- if exists toggle; otherwise launch
  if self:has(key, kind) then
    self:hide_all_except(kind, key)
    self[kind][key]:toggle()
  else
    local function delete_if_matches(c)
      client.disconnect_signal("unmanage", delete_if_matches)
      if c.class == key then self:del(key, kind) end
    end
    client.connect_signal("unmanage", delete_if_matches)

    local function track_if_matches(c)
      client.disconnect_signal("manage", track_if_matches)
      if c.class == key then self:track(c) end
    end
    client.connect_signal("manage", track_if_matches) -- to get out-of-band clients
    launch(function(ok)
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
  local key = c.class
  local kind = self.kinds[key]
  if not self:has(key, kind) then
    self[kind][key] = Scratch.new(c, kind)
    return true
  end
  c:kill()
  return false
end

function Manager:toggle_dev_console(domain)
  local key = dev_console.class
  local kind = self.kinds[key]
  self:toggle(key, kind, function(cb) x.cmd.dev_console(domain, cb) end)
end

function Manager:toggle_notes()
  local key = notes.class
  local kind = self.kinds[key]
  self:toggle(key, kind, x.cmd.notes)
end

function Manager:toggle_matrix()
  local key = matrixc.class
  local kind = self.kinds[key]
  self:toggle(key, kind, x.cmd.matrix)
end

return M
