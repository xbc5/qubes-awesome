local gears = require("gears")
local awful = require("awful")

local M = {}

-- Create an imagebox widget which will contain an icon indicating which layout we're using.
-- @param s An Awesome screen
function M.icon(s)
    local a = awful.button({ }, 1, function () awful.layout.inc( 1) end)
    local b = awful.button({ }, 3, function () awful.layout.inc(-1) end)
    local c = awful.button({ }, 4, function () awful.layout.inc( 1) end)
    local d = awful.button({ }, 5, function () awful.layout.inc(-1) end)

    s.mylayoutbox:buttons(gears.table.join(a, b , c, d))
end

return M
