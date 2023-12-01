local awful = require("awful")
local x = {
  notify = require("x.notify"),
}

local M = {}

-- Run any command asynchronously. It notifies and logs errors.
-- @param cmd The command (string) to run.
-- @param cb An optional callback, called after the command completes: cb(ok, stdout, stderr),
--   where ok is `exit_code == 0`.
-- @param silent bool: don't notify on errors?
function M.async(cmd, cb, silent)
  awful.spawn.easy_async(cmd, function(stdout, stderr, _, exit_code)
    if not silent and exit_code > 0 then
      x.notify.run_error(cmd, stderr)
    end
    -- we may pass a boolean own from some other part of the code, so
    -- cb could be anything -- check for explicit function. This approach
    -- means less type checking elsewhere in the app, this is also a safer approach.

    if type(cb) == "function" then
      cb(exit_code == 0, stdout, stderr)
    end
  end)
end

-- Start matrix.
-- @param cb An optional callback, called after the command completes: cb(ok, stdout, stderr),
--   where ok is `exit_code == 0`.
function M.matrix(cb)
  M.async("matrix --wait", cb)
end

function M.ide(qube, cb)
  M.async("ide " ..  qube, cb)
end

function M.start_email(cb)
  M.async("email", cb)
end

-- Run the email client
function M.spawn_email(cb)
  M.async("email", cb)
end

function M.stop_email(cb)
  M.async("email x --wait", cb)
end

function M.restart_email(cb)
  M.async("email r", cb)
end

function M.start_fin(cb)
  M.async("fin --wait", cb)
end

-- Run the email client
function M.spawn_fin(cb)
  M.async("fin --wait", cb)
end

function M.stop_fin(cb)
  M.async("fin --wait --shutdown", cb)
end

function M.restart_fin(cb)
  M.async("fin --wait --restart", cb)
end

-- Shutdown a qube.
-- @param qube The qube name.
-- @param cb he callback, called after the command completes: cb(ok, stdout, stderr),
--   where ok is `exit_code == 0`.
function M.shutown(qube, cb)
  if not string.match(qube, "[dD]om0") then
    M.async("qvm-shutdown --wait " .. qube, cb)
  end
end

local Qube = {}
Qube.__index = Qube

function Qube.new(start, stop, spawn)
  local self = setmetatable({}, Qube)
  self._start = start
  self._stop = stop
  self._spawn = spawn

  if not self._start then error("no start command") end
  if not self._stop then error("no stop command") end
  if not self._spawn then error("no spawn command") end
  return self
end

-- Start the qube.
-- @param cb fn(ok, stdout, stderr)
function Qube:start(cb) M.async(self._start, cb) end

-- Stop the qube.
-- @param cb fn(ok, stdout, stderr)
function Qube:stop(cb) M.async(self._stop, cb) end

-- Spawn a client. It should also start the qube.
-- @param cb fn(ok, stdout, stderr)
function Qube:spawn(cb) M.async(self._spawn, cb) end

M.notes = Qube.new("notes --wait", "notes --wait --shutdown", "notes --wait")
M.daily = Qube.new("daily --wait --start", "daily --wait --shutdown", "daily --wait")
M.dev_e = Qube.new("dev --wait --start", "dev --wait --shutdown", "dev --wait --ide")
M.dev_t = Qube.new("dev --wait --start", "dev --wait --shutdown", "dev --wait --terminal")
M.dev_b = Qube.new("dev --wait --start", "dev --wait --shutdown", "dev --wait --browser")
M.dev_s = Qube.new("dev-s --wait --start", "dev-s --wait --shutdown", "dev-s --wait --ide")

-- Start a 'developer console' on a qube, or Dom0.
-- @param domain [OPTIONAL] A qube name, or Dom0.
-- @param cb An optional callback, called after the command completes: cb(ok, stdout, stderr),
--   where ok is `exit_code == 0`.
function M.dev_console(domain, cb)
  M.async("developer-console " .. domain, cb)
end

-- Control the volume.
-- @param cmd Up, down, or mute.
-- @param cb An optional callback, called after the command completes: cb(ok, stdout, stderr),
--   where ok is `exit_code == 0`.
function M.volume(cmd, cb)
  M.async("volume " .. cmd, cb)
end

return M
