local awful = require("awful")
local gears = require("gears")
local qubes = require("qubes")
local x = {
  xprop = require("x.xprop"),
}

local M = {}

local SIZE = 10

function M.default_props(c, overrides)
  local defaults = {
    size = SIZE,
    bg_normal = qubes.get_colour(c),
    bg_focus = qubes.get_colour_focus(c),
  }
  return gears.table.crush(defaults, overrides or {})
end

client.connect_signal("request::titlebars", function(c)
  -- dev console has titlebars at the bottom
  if string.match(c.class, x.xprop.dev_console.class_p) then
    local overrides =  {
      position = "bottom",
      size = SIZE / 2,
    }
    awful.titlebar(c, M.default_props(c, overrides))
  else
    awful.titlebar(c, M.default_props(c))
  end
end)

return M
