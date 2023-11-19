local awful = require("awful")

local M = {
  defaults = {
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
      spec = { },
    },
    { name = "dev-s",
      key = "i",
      spec = { },
    },
    { name = "dom0",
      key = "s",
      spec = { },
    },
    { name = "read",
      key = "r",
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
  -- specs are thinly specified, and if absent, we shall set a default if we have one
  for _, tg in pairs(M.specs) do
    for key, _ in pairs(M.defaults) do -- e.g. a key is: layouts, gap etc.
      -- a spec is e.g.: { layout = x, ... }, from M.specs[].spec
      if tg.spec[key] == nil then tg.spec[key] = M[key] end -- use defaults from M.defaults
    end
    tg.spec.screen = s
    awful.tag.add(tg.name, tg.spec)
  end
end

return M
