local awful = require("awful")
local gears = require("gears")

local xtag = require("x.tag")
local xnotify = require("x.notify")

local M = {}

local Tag = {}
Tag.__index = Tag

function Tag.new(tag)
  local self = setmetatable({}, Tag)

  return self
end

-- Create the Awesome tag.
-- @param tag A tag spec { name: string; key: string, spec: {...props}}
function Tag:create(tag)
  if not tag.name then error("You must set a tag name") end
  if not tag.key then error("You must set a key for tag '" .. tag.name .. "'") end

  local defaults = {
    screen             = awful.screen.primary, -- override this below for multi-screen setups
    layout             = awful.layout.suit.max,
    master_fill_policy = "master_width_factor",
    gap_single_client  = false,
    gap                = 3,
  }
  self.tag = tag
  local spec = gears.table.crush(defaults, tag.spec or {})
  awful.tag.add(tag.name, spec)
end

function Tag:name()
  return self.tag.name
end

function Tag:spawn(cb)
  error("Not implemented")
end

function Tag:stop()
  error("Not implemented")
end

function Tag:gkeys()
  error("Not implemented")
end

-- Return client rules
function Tag:rule()
  error("Not implemented")
end

-- Find and return the live tag.
-- @return An Awesome tag.
function Tag:get()
  return xtag.get(self:name())
end

function Tag:view()
  self:spawn(function(ok)
    -- BUG: this won't execute if the VM has to start; however, it's desired behaviour,
    -- and the alternative is more complex code. Leavng it as-is.
    if ok then xtag.view(self:name()) end
  end)
end

M.Tag = Tag

return M
