local awful = require("awful")

local xprop = require("x.xprop")
local xtag = require("x.xtag")
local xnotify = require("x.notify")
local cmd = require("x.cmd")

local M = {}

-- Match a fin client
-- @param c Client
-- @return bool
function M.is_client(c)
  return awful.rules.match_any(c, xprop.fin_client_rulep())
end

function M.is_domain(c)
  return awful.rules.match_any(c, xprop.fin_rulep())
end

local Fin = {}
Fin.__index = Fin

function Fin.new()
  local self = setmetatable(Fin, xtag.Tag)
  self:create({ name = "fin", key = "f" })

  client.connect_signal("unmanage", function(c)
    if M.is_client(c) then self:stop() end
  end)

  return self
end

function Fin:stop()
  cmd.stop_fin()
end

function Fin:spawn(cb)
  -- only ever a single client
  for _, c in pairs(client.get()) do
    if M.is_client(c) then return cb(true) end
  end
  cmd.spawn_fin(cb)
end

function Fin:restart()
  cmd.fin_restart()
end

function Fin:rule()
  return {
    rule_any = xprop.fin_rulep(), -- any app
    properties = { tag = self:get() }
  }
end

function Fin:gkeys()
  return awful.key({ require("x.key").mod }, self.tag.key,
                   function() self:view() end,
                   { description = self.tag.name, group = "tag" })
end

M.tag = Fin.new()

return M
