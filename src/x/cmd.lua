local awful = require("awful")
local x = {
  notify = require("x.notify"),
}

local M = {}

-- Run any command asynchronously. It notifies and logs errors.
-- @param cmd The command (string) to run.
-- @param cb An optional callback, called after the command completes: cb(ok, stdout, stderr),
--   where ok is `exit_code == 0`.
function M.async(cmd, cb)
  awful.spawn.easy_async(cmd, function(stdout, stderr, _, exit_code)
    if exit_code > 0 then
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

-- Start notes.
-- @param cb An optional callback, called after the command completes: cb(ok, stdout, stderr),
--   where ok is `exit_code == 0`.
function M.notes(cb)
  M.async("notes --wait", cb)
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

-- Shutdown a qube.
-- @param qube The qube name.
-- @param cb he callback, called after the command completes: cb(ok, stdout, stderr),
--   where ok is `exit_code == 0`.
function M.shutown(qube, cb)
  if not string.match(qube, "[dD]om0") then
    M.async("qvm-shutdown --wait " .. qube, cb)
  end
end

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
