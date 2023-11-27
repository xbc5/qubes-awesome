local awful = require("awful")

local xprop = require("x.xprop")
local xtag = require("x.xtag")
local xnotify = require("x.notify")
local cmd = require("x.cmd")

local M = {}

-- Match an email client window.
-- @param c Client
-- @return bool
function M.is_client(c)
  return awful.rules.match_any(c, xprop.email_client_rulep())
end

local Email = {}
Email.__index = Email

function Email.new()
  local self = setmetatable(Email, xtag.Tag)
  self:create({ name = "email", key = "e" })

  client.connect_signal("unmanage", function(c)
    if M.is_client(c) then self:stop() end
  end)

  return self
end

function Email:stop()
  cmd.stop_email()
end

function Email:spawn(cb)
  -- only ever a single client
  for _, c in pairs(client.get()) do
    if M.is_client(c) then return cb(true) end
  end
  cmd.spawn_email(cb)
end

function Email:restart()
  cmd.start_restart()
end

function Email:rule()
  return {
    rule_any = xprop.email_rulep(),
    properties = { tag = self:get() }
  }
end

function Email:gkeys()
  return awful.key({ require("x.key").mod }, self.tag.key,
                   function() self:view() end,
                   { description = self.tag.name, group = "tag" })
end

M.tag = Email.new()

return M
