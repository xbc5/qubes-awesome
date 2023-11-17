local awful = require("awful")

local M = {
  names = { daily = "daily", dev = "dev", dev_s = "dev-s" },
  gap = 3,
}

-- Return a taglist widget.
function M.list(s)
  return awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.noempty,
  }
end

function M.init(s)
  local n = M.names

  awful.tag.add(n.daily, {
    layout             = awful.layout.suit.max,
    master_fill_policy = "master_width_factor",
    gap_single_client  = false,
    gap                = M.gap,
    screen             = s,
    selected           = true,
  })

  awful.tag.add(n.dev, {
    layout             = awful.layout.suit.max,
    master_fill_policy = "master_width_factor",
    gap_single_client  = false,
    gap                = M.gap,
    screen             = s,
    selected           = false,
  })

  awful.tag.add(n.dev_s, {
    layout             = awful.layout.suit.max,
    master_fill_policy = "master_width_factor",
    gap_single_client  = false,
    gap                = M.gap,
    screen             = s,
    selected           = false,
  })
end

return M
