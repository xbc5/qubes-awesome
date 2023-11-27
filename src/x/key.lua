local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
local xemail = require("x.email")
local x = {
  app = require("x.app"),
  cmd = require("x.cmd"),
  layout = require("x.layout"),
  tag = require("x.tag"),
  scratch = require("x.scratch"),
  qube = require("x.qube"),
  xprop = require("x.xprop"),
}

local M = {
  mod = "Mod4"
}

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

function M.client()
  if M._client ~= nil then return M._client end

  M._client = gears.table.join(
    x.scratch.key.client(M.mod),

    awful.key({ M.mod, "Shift" }, "f",
              function(c) toggle_fullscreen(c) end,
              { description = "toggle fullscreen", group = "client" }),

    awful.key({ M.mod, "Shift" }, "c",
              function(c) c:kill() end,
              { description = "close", group = "client" }),

    awful.key({ M.mod, "Shift" }, "0",
              function(c) c.floating = not c.floating end,
              { description = "toggle floating", group = "client" }),

    awful.key({ M.mod, "Alt" }, "Return",
              function(c) awful.client.setmaster(c) end,
              { description = "move to master", group = "client" }),

    awful.key({ M.mod, "Shift" }, "t",
              function(c) c.ontop = not c.ontop end,
              { description = "toggle keep on top", group = "client" }),

    awful.key({ M.mod }, "-",
              function(c) c.minimized = true end,
              { description = "minimize", group = "client" }),

    awful.key({ M.mod, "Shift" }, "-",
              function() awful.client.restore(awful.screen.focused()) end,
              { description = "minimize", group = "client" }),

    awful.key({ M.mod, "Shift" }, "m",
              function(c) toggle_maximised(c) end,
              { description = "(un)maximize", group = "client" }))

  return M._client
end


-- Get a table of awful.key specifications. This is created only once, then cached.
-- You will need to add these to root.keys(). Feel free to call this function multiple times,
-- safe in the knowledge that it creates keys only once.
function M.global()
  if M._global ~= nil then return M._global end

  local _tags = {}
  for _, spec in pairs(x.tag.specs) do
    -- FIXME: very inefficient (N^3) -- join uses nested loops and select(), where select
    -- uses progressive slices, and join increments those slices, then this uses a loop.
    -- This is only run once, and it's a small data structure; it's probably not worth the effort.
    _tags = gears.table.join(
      _tags,
      awful.key({ M.mod }, spec.key,
                function() x.tag.view(spec.name) end,
                { description = "view " .. spec.name .. "tag", group = "tag" }),
      awful.key({ M.mod, "Control" }, spec.key,
                function() x.tag.move(spec.name) end,
                { description = "move " .. spec.name .. "tag", group = "tag" }))
  end

  local _layouts = {}
  for i, lay in pairs(x.layout.layouts) do
    _layouts = gears.table.join(
      _layouts,
      awful.key({ M.mod }, i,
                function() awful.layout.set(lay.l) end,
                { description = "set " .. lay.name, group = "layout" }))
  end

  M._global = gears.table.join(
    _tags,
    _layouts,
    x.scratch.key.global(M.mod),
    xemail.tag:gkeys(),

    -- volume
    awful.key({ M.mod }, "F1",
              function() x.cmd.volume("mute") end,
              { description = "mute", group = "system" }),

    awful.key({ M.mod }, "F2",
              function() x.cmd.volume("down") end,
              { description = "volume down", group = "system" }),

    awful.key({ M.mod }, "F3",
              function() x.cmd.volume("up") end,
              { description = "volume up", group = "system" }),

    awful.key({ M.mod, "Shift" }, "p",
              function() x.cmd.ide(x.qube.dev) end,
              { description = x.qube.dev .. " IDE", group = "launcher" }),

    awful.key({ M.mod, "Shift" }, "i",
              function() x.cmd.ide(x.qube.dev_s) end,
              { description = x.qube.dev_s .. " IDE", group = "launcher" }),

    awful.key({ M.mod, "Shift" }, "s",
              hotkeys_popup.show_help,
              { description = "show help", group = "awesome" }),

    awful.key({ M.mod }, "j",
              function() awful.client.focus.byidx(1) end,
              { description = "focus next by index", group = "client" }),

    awful.key({ M.mod }, "k",
              function() awful.client.focus.byidx(-1) end,
              { description = "focus previous by index", group = "client" }),

    -- Layout manipulation
    awful.key({ M.mod, "Shift" }, "j",
              function() awful.client.swap.byidx(1) end,
              { description = "swap with next client by index", group = "client" }),

    awful.key({ M.mod, "Shift" }, "k",
              function() awful.client.swap.byidx(-1) end,
              { description = "swap with previous client by index", group = "client" }),

    awful.key({ M.mod, "Control" }, "j",
              function() awful.screen.focus_relative(1) end,
              { description = "focus the next screen", group = "screen" }),

    awful.key({ M.mod, "Control" }, "k",
              function() awful.screen.focus_relative(-1) end,
              { description = "focus the previous screen", group = "screen" }),

    awful.key({ M.mod }, "u",
              awful.client.urgent.jumpto,
              { description = "jump to urgent client", group = "client" }),

    awful.key({ M.mod }, "Tab",
              function() switch_client() end,
              { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ M.mod, "Shift" }, "Return",
              function() awful.spawn(x.app.terminal()) end,
              { description = "terminal", group = "launcher" }),

    awful.key({ M.mod, "Shift" }, "r",
              function() awesome.restart() end,
              { description = "reload awesome", group = "awesome" }),

    awful.key({ M.mod, "Shift" }, "q",
              function() awesome.quit() end,
              { description = "quit awesome", group = "awesome" }),

    awful.key({ M.mod }, "l",
              function() awful.tag.incmwfact(0.05) end,
              { description = "width++", group = "layout" }),

    awful.key({ M.mod }, "h",
              function() awful.tag.incmwfact(-0.05) end,
              { description = "width--", group = "layout" }),

    awful.key({ M.mod, "Shift" }, "h",
              function() awful.tag.incnmaster(1, nil, true) end,
              { description = "master clients++", group = "layout" }),

    awful.key({ M.mod, "Shift" }, "l",
              function() awful.tag.incnmaster(-1, nil, true) end,
              { description = "master clients--", group = "layout" }),

    -- resize width
    awful.key({ M.mod, "Control" }, "h",
              function() awful.tag.incncol(1, nil, true) end,
              { description = "columns++", group = "layout" }),

    awful.key({ M.mod, "Control" }, "l",
              function() awful.tag.incncol(-1, nil, true) end,
              { description = "colimns--", group = "layout" }),

    -- run
    awful.key({ M.mod }, "p",
              function() menubar.show() end,
              { description = "show the menubar", group = "launcher" }))

    return M._global
end

return M
