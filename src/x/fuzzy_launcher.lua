local awful = require("awful")
local xprop = require("x.xprop")

local M = {
  rules = { class = { xprop.rofi.class_p } }
}

client.connect_signal("manage", function(c)
  if awful.rules.match_any(c, M.rules) then
    c.ontop = true
    c.above = true
    c.sticky = true
    c.skip_taskbar = true
    c.floating = true
    c.screen = awful.screen.focused()

    -- take up all of the bottom half of the screen
    awful.placement.bottom(c)
    awful.placement.maximize_horizontally(c)
    awful.placement.stretch_down(c)

    client.focus = c
    c:raise()
  end
end)

return M
