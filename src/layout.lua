local gears = require("gears")
local awful = require("awful")

local M = {}

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier,
  awful.layout.suit.corner.nw,
}

-- Return an imagebox widget which will contain an icon indicating which layout we're using.
-- If necessary, it will also add it to the screen table as "layout_icon".
-- @param s An Awesome screen
function M.icon(s)
  if s.layout_icon ~= nil then
    return s.layout_icon
  end

  local layout_icon = awful.widget.layoutbox(s)

  local a = awful.button({ }, 1, function () awful.layout.inc( 1) end)
  local b = awful.button({ }, 3, function () awful.layout.inc(-1) end)
  local c = awful.button({ }, 4, function () awful.layout.inc( 1) end)
  local d = awful.button({ }, 5, function () awful.layout.inc(-1) end)

  layout_icon:buttons(gears.table.join(a, b , c, d))

  s.layout_icon = layout_icon
  return s.layout_icon
end

return M
