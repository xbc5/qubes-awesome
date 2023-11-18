local awful = require("awful")
local qubes = require("qubes")
local x = {
  key = require("x.key"),
  tag = require("x.tag"),
  notify = require("x.notify"),
}

local M = {}

function M.offscreen(c)
  local ppos = c.size_hints.program_position
  local upos = c.size_hints.user_position
  return not (upos or ppos)
end


client.connect_signal("manage", function (c)
  qubes.manage(c) -- sets qubes_vmname, qubes_label, qubes_prefix (e.g. [dom0]), and border_colour

  x.notify.test(c.qubes_vmname)

  -- config goes here
  c.border_width = 0

  if awesome.startup and M.offscreen(c) then
    awful.placement.no_offscreen(c)
  end
end)

-- Put the Qube name in front of all displayed names (tilebars, tasklists, ...)
client.connect_signal("property::name", function(c) qubes.set_name(c) end)

-- Clients can match multiple rules, in order of specification.
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = {
        focus = awful.client.focus.filter,
        raise = true,
        keys = x.key.client(),
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen
      }
    },

    -- Floating clients.
    {
      rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"
        },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",    -- Thunderbird's calendar.
        }
      },
      properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
      rule_any = {
        type = { "normal", "dialog" }
      },
      properties = { titlebars_enabled = true }
    },
}

return M
