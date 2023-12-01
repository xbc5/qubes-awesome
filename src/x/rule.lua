local awful = require("awful")
local xemail = require("x.email")
local xfin = require("x.fin")
local xtag = require("x.xxtag")
local x = {
  key = require("x.key"),
  tag = require("x.tag"),
}
local xp = require("x.xprop")

-- unnecessary (it's done in rc.lua), but just in case.
-- Tags must be initalised before assignments happen here.
x.tag.init()

-- Clients can match multiple rules, in order of specification.
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = {
        border_width = 0,
        focus = awful.client.focus.filter,
        keys = x.key.client(),
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen,
      }
    },

    xemail.tag:rule(),
    xfin.tag:rule(),

    -- dev-s
    { rule = { class = xp.dev_s.class_p },
      properties = { tag = x.tag.get(x.tag.name.dev_s) }},

    -- dev:e
    { rule_any = xp.ide_rule(xp.dev.class_p),
      properties = { tag = x.tag.get(x.tag.name.dev_e) }},

    -- dev:b
    { rule_any = xp.browser_rule(xp.dev.class_p), -- all browsers
      properties = { tag = x.tag.get(x.tag.name.dev_b) }},

    -- daily
    { rule_any = xp.browser_rule(xp.daily.class_p), -- all browsers
      properties = { tag = x.tag.get(x.tag.name.daily) }},

    -- Floating clients.
    { rule_any = {
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
    { rule_any = {
        type = { "normal", "dialog" }
      },
      properties = { titlebars_enabled = true }
    },
}

table.insert(awful.rules.rules, xtag.notes:rule())

return M
