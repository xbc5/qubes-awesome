local awful = require("awful")
local gears = require("gears")
local x = {
  xprop = require("x.xprop"),
  notify = require("x.notify"),
  cmd = require("x.cmd"),
  util = require("x.util"),
  client = require("x.client"),
}

local M = {
  key = {
    global = {},
    client = {},
  },
}


-- Hide everything of the same kind except one item.
-- @param c An Awesome clent.
-- @return nil.
local function hide_all_except(c)
  for _, client in pairs(client.get()) do
    -- hide same kind, but skip c
    if client.xkind == c.xkind and not rawequal(c, client) then
      client.xhide()
    end
  end
end

function M.is_scratch(c)
  return awful.rules.match_any(c, x.xprop.scratch_rulep())
end

-- Add xutility functions and configuration properties to a client.
-- If c.xscratch is true, then it's decorated.
-- @return nil
local function decorate(c)
  if c.xscratch == true then return end

  c.floating = true
  c.sticky = true
  c.skip_taskbar = true
  c.hidden = true
  c.screen = awful.screen.focused()

  c.xscratch = true -- used for filtering

  if awful.rules.match_any(c, x.xprop.modal_rulep()) then
    c.xkind = "modal"  -- for scan+track
    c.above = true
    c.xshutdown = true -- shutdown qube if client closed
    c.fullscreen = true
  elseif awful.rules.match_any(c, x.xprop.dev_console_rulep()) then
    c.xkind = "dev_console" -- for scan+track
    c.ontop = true
    x.client.set_rel_height(c, 0.75)
    awful.placement.top(c)
    awful.placement.maximize_horizontally(c)
  else
    error("unknown scratch kind: " .. c.class)
  end

  function c.xfocus()
    client.focus = c
    c:raise()
  end

  function c.xhide()
    c.hidden = true
  end

  function c.xshow()
    hide_all_except(c)
    c.hidden = false
    c.xfocus()
  end

  function c.xclose()
    if c.xshutdown then
      x.cmd.shutown(c.qubes_vmname, c.xshutdown)
    end
  end

  function c.xtoggle()
    if c.hidden then c.xshow() else c.xhide() end
  end
end

local Manager = {}
local MetaManager = { __index = Manager }

function Manager.new()
  local self = setmetatable({}, MetaManager)
  return self -- self (huehue)
end

-- Scan and decorate all active scratch windows -- useful after refreshing Awesome.
-- @return nil
function Manager:scan()
  for _, c in pairs(client.get()) do
    if M.is_scratch(c) then decorate(c) end
  end
end

-- Hide everything. Useful during startup to prevent
-- refreshes from displaying all hidden clients.
-- @return nil
function Manager:hide_all()
  for _, c in pairs(client.get()) do
    if M.is_scratch(c) then c.xhide() end
  end
end

-- Get a single client.
-- @param class The X.class name.
-- @return An Awesome client.
function Manager:get(class)
  local chosen = nil
  for _, c in pairs(client.get()) do
    if c.xscratch and c.class == class then
      chosen = c
      break
    end
  end
  return chosen
end


-- Launch a client if it doesn't exist; toggle its visibility
-- if it does.
-- @param class the literal class name (not a pattern)
-- @param launcher A function for starting the client: fn(). Preferrably async.
-- @return nil
function Manager:toggle(class, launcher)
  -- Client exists, use it (toggle it).
  local c = self:get(class)
  if c ~= nil then
    c.xtoggle()
    return
  end

  launcher()
end

-- Start a developer console.
-- @param domain The name of the domain to run it on: e.g. dom0, foo.
-- @return nil
function Manager:toggle_dev_console(domain)
  -- we use domain:app so that we can toggle between
  -- consoles on different domains.
  self:toggle(
    x.xprop.dev_console.full_class(domain), -- provides domain:app
    function(cb)
      x.cmd.dev_console(domain, cb)
    end)
end

-- Start the notes application.
-- @return nil
function Manager:toggle_notes()
  self:toggle(x.xprop.notes.class, x.cmd.notes)
end

-- Start the matrix client.
-- @return nil
function Manager:toggle_matrix()
  self:toggle(x.xprop.matrix_c.class, x.cmd.matrix)
end

M.manager = Manager.new()

client.connect_signal("unmanage", function(c)
  if awful.rules.match_any(c, x.xprop.scratch_rulep()) then
    c.xclose()
  end
end)

client.connect_signal("manage", function(c)
  if awful.rules.match_any(c, x.xprop.scratch_rulep()) then
    decorate(c)
    c.xshow()
  end
end)

awesome.connect_signal("startup", function()
  M.manager:scan()
  M.manager:hide_all()
end)

function M.key.client(mod)
  if M.key._client ~= nil then return M.key._client end

  local k = awful.key({ mod }, "Return",
                      function(c) M.manager:toggle_dev_console(c.qubes_vmname) end,
                      { description = "contextual developer console", group = "launcher" })

  M.key._client = k
  return M.key._client
end


function M.key.global(mod)
  if M.key._global ~= nil then return M.key._global end

  M.key._global = gears.table.join(
    awful.key({ mod }, "Escape",
              function() M.manager:scan() end,
              { description = "reset views to a sane default", group = "awesome" }),

    awful.key({ mod }, "y",
              function() M.manager:toggle_matrix() end,
              { description = "matrix", group = "scratch" }),

    awful.key({ mod }, ",",
              function() M.manager:toggle_notes() end,
              { description = "notes", group = "scratch" }))

    return M.key._global
end

-- when sticky is focused, prevent interaction with background elements -- e.g. movement:
--  enable only the keys relevant to that scratch.
client.connect_signal("focus", function(c)
  if M.is_scratch(c) then
    root.keys(M.key.global())
  end
end)

client.connect_signal("unfocus", function(c)
  if M.is_scratch(c) then
    root.keys(require("x.key").global()) -- everything
  end
end)

return M
