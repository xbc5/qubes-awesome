local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local M = {}

local function toggle_fullscreen(c)
  c.fullscreen = not c.fullscreen
  c:raise()
end

local function toggle_maximised(c)
  c.maximized = not c.maximized
  c:raise()
end

local function switch_client()
  awful.client.focus.history.previous()
  if client.focus then client.focus:raise() end
end

local MOD = "Mod4"

function M.client()
  if M._client ~= nil then return M._client end

  M._client = gears.table.join(
    awful.key({ MOD }, "f",
              function(c) toggle_fullscreen(c) end,
              { description = "toggle fullscreen", group = "client" }),

    awful.key({ MOD, "Shift" }, "c",
              function(c) c:kill() end,
              { description = "close", group = "client" }),

    awful.key({ MOD, "Control" }, "space",
              awful.client.floating.toggle,
              { description = "toggle floating", group = "client" }),

    awful.key({ MOD, "Control" }, "Return",
              function(c) c:swap(awful.client.getmaster()) end,
              { description = "move to master", group = "client" }),

    awful.key({ MOD }, "o",
              function(c) c:move_to_screen() end,
              { description = "move to screen", group = "client" }),

    awful.key({ MOD }, "t",
              function(c) c.ontop = not c.ontop end,
              { description = "toggle keep on top", group = "client" }),

    awful.key({ MOD }, "n",
              function(c) c.minimized = true end,
              { description = "minimize", group = "client" }),

    awful.key({ MOD }, "m",
              function(c) toggle_maximised(c) end,
              { description = "(un)maximize", group = "client" }))

  return M._client
end

-- Get a table of awful.key specifications. This is created only once, then cached.
-- You will need to add these to root.keys(). Feel free to call this function multiple times,
-- safe in the knowledge that it creates keys only once.
function M.global()
  if M._global ~= nil then return M._global end

  M._global = gears.table.join(
    awful.key({ MOD }, "s",
              hotkeys_popup.show_help,
              { description = "show help", group = "awesome" }),

   awful.key({ MOD }, "Left",
             awful.tag.viewprev,
             { description = "view previous", group = "tag" }),

   awful.key({ MOD }, "Right",
             awful.tag.viewnext,
             { description = "view next", group = "tag" }),

   awful.key({ MOD }, "Escape",
             awful.tag.history.restore,
             { description = "go back", group = "tag" }),

    awful.key({ MOD }, "j",
              function() awful.client.focus.byidx(1) end,
              { description = "focus next by index", group = "client" }),

    awful.key({ MOD }, "k",
              function() awful.client.focus.byidx(-1) end,
              { description = "focus previous by index", group = "client" }),

    -- Layout manipulation
    awful.key({ MOD, "Shift" }, "j",
              function() awful.client.swap.byidx(1) end,
              { description = "swap with next client by index", group = "client" }),

    awful.key({ MOD, "Shift" }, "k",
              function() awful.client.swap.byidx(-1) end,
              { description = "swap with previous client by index", group = "client" }),

    awful.key({ MOD, "Control" }, "j",
              function() awful.screen.focus_relative(1) end,
              { description = "focus the next screen", group = "screen" }),

    awful.key({ MOD, "Control" }, "k",
              function() awful.screen.focus_relative(-1) end,
              { description = "focus the previous screen", group = "screen" }),

    awful.key({ MOD }, "u",
              awful.client.urgent.jumpto,
              { description = "jump to urgent client", group = "client" }),

    awful.key({ MOD }, "Tab",
              function() switch_client() end,
              { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ MOD }, "Return",
              function() awful.spawn(terminal) end,
              { description = "open a terminal", group = "launcher" }),

    awful.key({ MOD, "Control" }, "r",
              awesome.restart,
              { description = "reload awesome", group = "awesome" }),

    awful.key({ MOD, "Shift" }, "q",
              awesome.quit,
              { description = "quit awesome", group = "awesome" }),

    awful.key({ MOD }, "l",
              function() awful.tag.incmwfact(0.05) end,
              { description = "increase master width factor", group = "layout" }),

    awful.key({ MOD }, "h",
              function() awful.tag.incmwfact(-0.05) end,
              { description = "decrease master width factor", group = "layout" }),

    awful.key({ MOD, "Shift" }, "h",
              function() awful.tag.incnmaster(1, nil, true) end,
              { description = "increase the number of master clients", group = "layout" }),

    awful.key({ MOD, "Shift" }, "l",
              function() awful.tag.incnmaster(-1, nil, true) end,
              { description = "decrease the number of master clients", group = "layout" }),

    -- resize width
    awful.key({ MOD, "Control" }, "h",
              function() awful.tag.incncol(1, nil, true) end,
              { description = "increase the number of columns", group = "layout" }),

    awful.key({ MOD, "Control" }, "l",
              function() awful.tag.incncol(-1, nil, true) end,
              { description = "decrease the number of columns", group = "layout" }),

    -- change layout
    awful.key({ MOD }, "space",
              function() awful.layout.inc(1) end,
              { description = "select next", group = "layout" }),

    awful.key({ MOD, "Shift" }, "space",
              function() awful.layout.inc(-1) end,
              { description = "select previous", group = "layout" }),

    -- run
    awful.key({ MOD }, "p",
              function() menubar.show() end,
              { description = "show the menubar", group = "launcher" }))

    return M._global
end

return M
