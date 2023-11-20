local gears = require("gears")
local awful = require("awful")
local x = {
  util = require("x.util"),
}

local M = {
  -- name is for cheatsheet
  layouts = {
    { l = awful.layout.suit.max, name = "max" },
    { l = awful.layout.suit.tile, name = "tile" },
    { l = awful.layout.suit.corner.nw, name = "corner.nw" },
    { l = awful.layout.suit.fair.horizontal, name = "horizontal" },
    { l = awful.layout.suit.tile.bottom, name = "tile.bottom" },
  },
}

awful.layout.layouts = x.util.map(M.layouts, function(v) return v.l end)

-- Return an imagebox widget which will contain an icon indicating which layout we're using.
-- If necessary, it will also add it to the screen table as "mylayoutbox".
-- @param s An Awesome screen
function M.icon(s)
  if s.mylayoutbox ~= nil then
    return s.mylayoutbox
  end

  local mylayoutbox = awful.widget.layoutbox(s)

  local a = awful.button({ }, 1, function () awful.layout.inc( 1) end)
  local b = awful.button({ }, 3, function () awful.layout.inc(-1) end)
  local c = awful.button({ }, 4, function () awful.layout.inc( 1) end)
  local d = awful.button({ }, 5, function () awful.layout.inc(-1) end)

  mylayoutbox:buttons(gears.table.join(a, b , c, d))

  s.mylayoutbox = mylayoutbox
  return s.mylayoutbox
end

return M
