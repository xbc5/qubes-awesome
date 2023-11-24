local qubes = require("qubes")

local M = {}

-- Set the height of a client relative to its screen.
-- @param c An awesome client.
-- @param factor An integer: 0 <= factor <= 1
-- @return An integer: the new height.
function M.set_rel_height(c, factor)
  local h = c.screen.geometry.height
  c.height = math.floor(h * factor)
  return c.height
end

-- Set the width of a client relative to its screen.
-- @param c An awesome client.
-- @param factor An integer: 0 <= factor <= 1
-- @return An integer: the new height.
function M.set_rel_width(c, factor)
  local w = c.screen.geometry.width
  c.width = math.floor(w * factor)
  return c.width
end

-- Set both the width and height of a client relative to its screen.
-- @param c An awesome client.
-- @param factor An integer: 0 <= factor <= 1
-- @return A table of the new values: { width: integer, height: integer }
function M.set_rel_size(c, factor)
  local w = M.set_rel_width(c, factor)
  local h = M.set_rel_height(c, factor)
  return { width = w, height = h }
end


client.connect_signal("manage", function (c)
  qubes.manage(c) -- sets qubes_vmname, qubes_label, qubes_prefix (e.g. [dom0]), and border_colour
end)

-- Put the Qube name in front of all displayed names (tilebars, tasklists, ...)
client.connect_signal("property::name", function(c) qubes.set_name(c) end)

return M
