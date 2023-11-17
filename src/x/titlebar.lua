local awful = require("awful")
local qubes = require("qubes")

local M = {}

-- Create the title bar for a client, and set its appropriate Qubes VM colour.
-- @param c An Awesome client.
-- @returns nil
function M.create(c)
  awful.titlebar(c, {
    height = 5,
    bg_normal = qubes.get_colour(c),
    bg_focus = qubes.get_colour_focus(c),
  })
end

return M
