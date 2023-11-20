local awful = require("awful")
local x = {
  xprop = require("x.xprop"),
  notify = require("x.notify"),
}

local notes = x.xprop.notes

local M = {
  keys = { notes = notes.class },
  clients = {}, -- a cache to hold active clients for easy searching
  rules = {
    modals = { class = { notes.class }, role = { "scratch:modal" } },
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
  if fn and not M.has(key) then return fn() end -- launch if no cached client
  local c = M.get(key)
  c.hidden = not c.hidden
end

client.connect_signal("manage", function(c)
  if awful.rules.match_any(c, M.rules.modals ) then
    c.role = "scratch:modal"
    c.floating = true
    c.ontop = true
    c.above = true
    c.sticky = true
    c.skip_taskbar = true
    c.hidden = false -- on creation
    c.screen = awful.screen.focused()

    M.add(c)
  end
end)

client.connect_signal("unmanage", function(c)
  if c.role == "scratch:modal" then
    M.del(c)
  end
end)

return M
