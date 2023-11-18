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

-- Return a tag object given its name
-- @param name The name of the tag
-- @param s An optional Aweome screen (defaults to the focused screen)
-- @return a Tag objecy
function M.get(name, s)
  return awful.tag.find_by_name(s or awful.screen.focused(), name)
end

-- Move a client to a tag -- i.e. make it "take" the client.
-- @param c An Awesome client
-- @param name The name of the tag
-- @param s An optional Awesome screen -- see tag.get() for defaults.
function M.take(c, name, s)
  c:move_to_tag(M.get(name, s))
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
