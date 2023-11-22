-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
require("x.rule")
require("x.fuzzy_launcher")
require("awful.autofocus")

local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local x = {
  client = require("x.client"), -- do this early: sets client props used by others
  key = require("x.key"),
  tag = require("x.tag"),
  task = require("x.task"),
  titlebar = require("x.titlebar"),
  toolbar = require("x.toolbar"),
}

x.tag.init()

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- per screen config
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
    x.toolbar.widget(s)
end)

root.keys(x.key.global())

awful.spawn('bash -c "pgrep -f -a qvm-start-daemon | grep -v $$ || dex-autostart -a -e XFCE"')
