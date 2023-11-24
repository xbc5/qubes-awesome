local qubes = require("qubes")

local M = {}

-- Set the height of a client relative to its screen.
-- @param c An awesome client.
-- @param An integer: 0 <= factor <= 1
-- @return An integer: the new height.
function M.set_rel_height(c, factor)
  local h = c.screen.geometry.height
  c.height = math.floor(h * factor)
  return c.height
end


client.connect_signal("manage", function (c)
  qubes.manage(c) -- sets qubes_vmname, qubes_label, qubes_prefix (e.g. [dom0]), and border_colour
end)

-- Put the Qube name in front of all displayed names (tilebars, tasklists, ...)
client.connect_signal("property::name", function(c) qubes.set_name(c) end)

return M
