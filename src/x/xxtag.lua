local awful = require("awful")
local gears = require("gears")

local xprop = require("x.xprop")
local tag = require("x.tag")
local xnotify = require("x.notify")
local cmd = require("x.cmd")

local M = {}

local XXTag = {}
XXTag.__index = XXTag

function XXTag.new(client_rulep, domain_rulep, cmd, rules)
  local self = setmetatable({}, XXTag)

  -- create the tags
  for key, spec in pairs(rules.view) do
    self:create({ name = spec.tagname, key = key, spec = spec.spec })
  end

  self._client_rulep = client_rulep
  self._domain_rulep = domain_rulep
  self._cmd = cmd
  self._rules = rules

  if rules.stop then
    client.connect_signal("unmanage", function(c)
      if awful.rules.match_any(c, rules.stop.rule()) then self._cmd:stop() end
    end)
  end

  if rules.view then
    client.connect_signal("manage", function(c)
      for _, spec in pairs(self._rules.view) do
        if awful.rules.match_any(c, spec.rule) then
          self:move(spec.tagname, c)
        end
      end
    end)
  end

  return self
end

function XXTag:move(name, c)
  local _c = c or client.focus
  _c:move_to_tag(self:get(name))
end

function XXTag:get(name)
  -- TODO #2
  return awful.tag.find_by_name(awful.screen.focused(), name)
end

function XXTag:create(tag)
  if not tag.name then error("You must set a tag name") end
  if not tag.key then error("You must set a key for tag '" .. tag.name .. "'") end

  local defaults = {
    screen             = awful.screen.primary, -- override this below for multi-screen setups
    layout             = awful.layout.suit.max,
    master_fill_policy = "master_width_factor",
    gap_single_client  = false,
    gap                = 3,
  }
  self.tag = tag
  local spec = gears.table.crush(defaults, tag.spec or {})
  awful.tag.add(tag.name, spec)
end

function XXTag:view(name)
  self:spawn(function(ok)
    -- BUG(#16): this won't execute if the VM has to start; however, it's desired behaviour,
    -- and the alternative is more complex code. Leavng it as-is.
    if ok then tag.view(name) end
  end)
end

function XXTag:is_client(c)
  return awful.rules.match_any(c, self._client_rulep())
end

function XXTag:is_domain(c)
  return awful.rules.match_any(c, self._domain_rulep())
end

function XXTag:stop()
  self._cmd:stop()
end

function XXTag:spawn(cb)
  -- only ever a single client
  for _, c in pairs(client.get()) do
    if self:is_client(c) then return cb(true) end
  end
  self._cmd:spawn(cb)
end

function XXTag:rule()
  -- _rules.view has { rule, tagname }: so put clients that match the rule, onto the tag
  local rules = {}
  for _, spec in pairs(self._rules.view) do
    gears.table.join(rules,
                     { rule_any = spec.rule,
                       properties = { tag = self:get(spec.tagname) }})
  end
  return rules
end

function XXTag:gkeys()
  -- _rules.view are keyed by their hotkey (e.g. x): { x = { rule, tagname }}; so map clients
  -- that match the rule, to a hotket that will view(tagname).
  local keys = {}
  for key, spec in pairs(self._rules.view) do
    keys = gears.table.join(keys,
                            awful.key({ require("x.key").mod }, key,
                            function() self:view(spec.tagname) end,
                            { description = spec.tagname, group = "tag" }))
  end
  return keys
end


M.notes = XXTag.new(xprop.notes_client_rulep,
                    xprop.notes_domain_rulep,
                    cmd.notes,
                    { view = { [","] = { rule = xprop.xnotes:pat():domain():app():build(true),
                                         tagname = "notes" }},
                      stop = { rule = xprop.notes_client_rulep }})

M.daily = XXTag.new(xprop.daily_client_rulep,
                    xprop.daily_domain_rulep,
                    cmd.daily,
                    { view = { ["m"] = { rule = xprop.daily_domain_rulep(),
                                         tagname = "daily" }}})
-- dev IDE
M.dev_e = XXTag.new(xprop.dev_e_client_rulep,
                    xprop.dev_domain_rulep,
                    cmd.dev_e,
                    { view = { ["n"] = { rule = xprop.dev_e_client_rulep(),
                                         tagname = "dev:e" }}})

-- dev browser
M.dev_b = XXTag.new(xprop.dev_b_client_rulep,
                    xprop.dev_domain_rulep,
                    cmd.dev_b,
                    { view = { ["b"] = { rule = xprop.dev_b_client_rulep(),
                                         tagname = "dev:b" }}})

-- dev terminal
M.dev_t = XXTag.new(xprop.dev_t_client_rulep,
                    xprop.dev_domain_rulep,
                    cmd.dev_t,
                    { view = { ["u"] = { rule = xprop.dev_t_client_rulep(),
                                         spec = { layout = awful.layout.suit.tile },
                                         tagname = "dev:t" }}})

-- dev dev:s
M.dev_s = XXTag.new(xprop.dev_s_client_rulep,
                    xprop.dev_s_domain_rulep,
                    cmd.dev_s,
                    { view = { ["i"] = { rule = xprop.dev_s_client_rulep(),
                                         tagname = "dev-s" }},
                                         stop = { rule = xprop.dev_s_client_rulep }})

return M
