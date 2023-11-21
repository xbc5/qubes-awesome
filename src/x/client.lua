local qubes = require("qubes")

local M = {}

client.connect_signal("manage", function (c)
  qubes.manage(c) -- sets qubes_vmname, qubes_label, qubes_prefix (e.g. [dom0]), and border_colour
end)

-- Put the Qube name in front of all displayed names (tilebars, tasklists, ...)
client.connect_signal("property::name", function(c) qubes.set_name(c) end)

return M
