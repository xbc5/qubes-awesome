local awful = require("awful")
local gears = require("gears")
local qubes = require("qubes")
local x = {
  xprop = require("x.xprop"),
}

local M = {}

function M.default_props(c, overrides)
  local defaults = {
    height = 5,
    bg_normal = qubes.get_colour(c),
    bg_focus = qubes.get_colour_focus(c),
  }
  return gears.table.crush(defaults, overrides or {})
end

client.connect_signal("request::titlebars", function(c)
  -- dev console has titlebars at the bottom
  if string.match(c.class, x.xprop.dev_console.class_p) then
    awful.titlebar(c, M.default_props(c, { position = "bottom" }))
  else
    awful.titlebar(c, M.default_props(c))
  end
end)

return M
