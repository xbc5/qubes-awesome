local awful = require("awful")
local x = {
  xprop = require("x.xprop"),
  notify = require("x.notify"),
}

local notes = x.xprop.notes
local dev_console = x.xprop.dev_console
local matrixc = x.xprop.matrix_c

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
