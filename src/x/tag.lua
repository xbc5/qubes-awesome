local awful = require("awful")
local gears = require("gears")
local x = {
  util = require("x.util"),
}

local M = {
  defaults = {
    -- keep this flat (no nested tables) otherwise do deep copy (see init fn)
    layout             = awful.layout.suit.max,
    master_fill_policy = "master_width_factor",
    gap_single_client  = false,
    gap                = 3,
  },
  specs = {
    { name = "daily",
      key = "m",
      spec = { selected = true, },
    },
    { name = "dev:b",
      key = "n",
      spec = { },
    },
    { name = "dev:t",
      key = "u",
      spec = {
        layout = awful.layout.suit.corner.nw,
      },
    },
    { name = "dev-s",
      key = "i",
      spec = { },
    },
    { name = "dom0",
      key = "s",
      spec = { },
    },
  }
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

-- View a tag
-- @param name The name of the tag.
-- @param s The [optional] screen that the tag resides -- defaults to the focused screen.
-- @return nil
function M.view(name, s)
  M.get(name, s):view_only()
end

-- Move a client to a tag.
-- @param name The name of the tag.
-- @param s The [optional] screen that the tag resides -- defaults to the focused screen.
-- @return nil
function M.move(name, s)
  client.focus:move_to_tag(M.get(name, s))
end

function M.init(s)
  -- merge specs into defaults, then use that
  for _, tg in pairs(M.specs) do
    local spec = gears.table.crush(x.util.shallow_copy(M.defaults), tg.spec)
    spec.screen = s
    awful.tag.add(tg.name, spec)
  end
end

return M
