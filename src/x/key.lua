local gears = require("gears")
local awful = require("awful")

local M = {}

local function toggle_fullscreen(c)
  c.fullscreen = not c.fullscreen
  c:raise()
end

local function toggle_maximised(c)
  c.maximized = not c.maximized
  c:raise()
end

local MOD = "Mod4"

function M.client()
  if M._client ~= nil then return M._client end

  M._client = gears.table.join(
    awful.key({ MOD }, "f",
              function(c) toggle_fullscreen(c) end,
              { description = "toggle fullscreen", group = "client" }),

    awful.key({ MOD, "Shift"   }, "c",
              function (c) c:kill() end,
              { description = "close", group = "client" }),

    awful.key({ MOD, "Control" }, "space",
              awful.client.floating.toggle,
              { description = "toggle floating", group = "client" }),

    awful.key({ MOD, "Control" }, "Return",
              function (c) c:swap(awful.client.getmaster()) end,
              { description = "move to master", group = "client" }),

    awful.key({ MOD }, "o",
              function (c) c:move_to_screen() end,
              { description = "move to screen", group = "client" }),

    awful.key({ MOD }, "t",
              function (c) c.ontop = not c.ontop end,
              { description = "toggle keep on top", group = "client" }),

    awful.key({ MOD }, "n",
              function (c) c.minimized = true end,
              { description = "minimize", group = "client" }),

    awful.key({ MOD }, "m",
              function(c) toggle_maximised(c) end,
              { description = "(un)maximize", group = "client" }))

    return M._client
end

return M
