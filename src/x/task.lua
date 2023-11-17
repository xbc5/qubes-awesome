local awful = require("awful")

local M = {}

function M.list(s)
  return awful.widget.tasklist {
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
  }
end

return M
