local awful = require("awful")
local gears = require("gears")
local x = {
  util = require("x.util"),
}

local M = {
  defaults = {
    -- keep this flat (no nested tables) otherwise do deep copy (see init fn)
    screen             = awful.screen.primary, -- override this below for multi-screen setups
    layout             = awful.layout.suit.max,
    master_fill_policy = "master_width_factor",
    gap_single_client  = false,
    gap                = 3,
  },
  name = { dev_s = "dev-s",
           dom0  = "dom0",
         }
}

M.specs = {
  { name = M.name.dev_s,
    key = "i",
    spec = { },
  },
  { name = M.name.dom0,
    key = "s",
    spec = { },
  },
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
-- @return a Tag object
function M.get(name, s)
  -- TODO: we shall use a unique set of tags across all screens, so is s==nil, search all screens #2
  return awful.tag.find_by_name(s or awful.screen.focused(), name)
end

-- Move a client to a tag -- i.e. make it "take" the client.
-- @param c An Awesome client
-- @param name The name of the tag
-- @param s An optional Awesome screen -- see tag.get() for defaults.
function M.take(c, name, s)
  -- TODO: remove screen requirements #2
  c:move_to_tag(M.get(name, s))
end

-- View a tag
-- @param name The name of the tag.
-- @param s The [optional] screen that the tag resides -- defaults to the focused screen.
-- @return nil
function M.view(name, s)
  -- TODO: remove s #2
  M.get(name, s):view_only()
end

-- Move a client to a tag.
-- @param name The name of the tag.
-- @param s The [optional] screen that the tag resides -- defaults to the focused screen.
-- @return nil
function M.move(name, s)
  -- TODO: remove s #2
  client.focus:move_to_tag(M.get(name, s))
end

-- Initialise all tags.
function M.init()
  if M._initialised then return end

  -- merge specs into defaults, then use that
  for _, tg in pairs(M.specs) do
    local spec = gears.table.crush(x.util.shallow_copy(M.defaults), tg.spec)
    awful.tag.add(tg.name, spec)
  end

  M._initialised = true
end

return M
