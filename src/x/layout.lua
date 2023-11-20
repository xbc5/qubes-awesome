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

function M.init()
  if M._initialised then return end
  awful.layout.layouts = x.util.map(M.layouts, function(v) return v.l end)
  M._initialised = true
end

return M
