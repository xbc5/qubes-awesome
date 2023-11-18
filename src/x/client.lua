local awful = require("awful")
local qubes = require("qubes")

local M = {}

function M.offscreen(c)
    local ppos = c.size_hints.program_position
    local upos = c.size_hints.user_position
    return not (upos or ppos)
end

client.connect_signal("manage", function (c)
    qubes.manage(c) -- sets qubes_name, qubes_label, qubes_prefix (e.g. [dom0]), and border_colour

    -- config goes here
    c.border_width = 0

    if awesome.startup and M.offscreen(c) then
        awful.placement.no_offscreen(c)
    end
end)

-- Put the Qube name in front of all displayed names (tilebars, tasklists, ...)
client.connect_signal("property::name", function(c) qubes.set_name(c) end)

return M
