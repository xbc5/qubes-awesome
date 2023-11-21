local awful = require("awful")
local wibox = require("wibox")
local x = {
  tag = require("x.tag"),
  task = require("x.task"),
  layout = require("x.layout"),
}

local M = {}

-- Create and return a wibar widget.
-- @param s An Awesome screen
function M.widget(s)
  if M._widget ~= nil then return M._widget end

  M._widget = awful.wibar({ position = "top", screen = s })

  x.layout.init() -- we probably want to set this before using layouts in the widget
  local h = wibox.layout.align.horizontal
  M._widget:setup {
    layout = h,
    { -- left
      layout = h,
      x.tag.list(s),
    },
    x.task.list(s), -- middle
    { -- right
      layout = h,
      wibox.widget.systray(),
      wibox.widget.textclock(),
      awful.widget.layoutbox(s),
    },
  }

  return M._widget
end

return M
