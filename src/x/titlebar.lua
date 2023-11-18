local awful = require("awful")
local qubes = require("qubes")

client.connect_signal("request::titlebars", function(c)
  awful.titlebar(c, {
    height = 5,
    bg_normal = qubes.get_colour(c),
    bg_focus = qubes.get_colour_focus(c),
  })
end)

return {}
