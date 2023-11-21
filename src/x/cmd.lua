local awful = require("awful")
local x = {
  notify = require("x.notify"),
}

local M = {}

-- Run any command asynchronously. It notifies and logs errors.
-- @param cmd The command (string) to run.
-- @param cb A callback: cb(ok, stdout, stderr) -- ok is true for exit_code == 0.
function M.async(cmd, cb)
  awful.spawn.easy_async(cmd, function(stdout, stderr, _, exit_code)
    if exit_code > 0 then
      x.notify.run_error(cmd, stderr)
    end
    cb(exit_code == 0, stdout, stderr)
  end)
end

-- Start notes. If successful, it calls the callback.
-- @param cb The callback: cb() -- no args; called when exit_code == 0.
function M.notes(cb)
  M.async("notes --wait", function(ok)
    if ok and cb then cb() end
  end)
end

function M.ide(qube, cb)
  M.async("ide " ..  qube, function(ok)
    if ok and cb then cb() end
  end)
end

-- Control the volume.
-- @param cmd Up, down, or mute.
-- @param cb The callback: cb() -- no args; called when exit_code == 0.
function M.volume(cmd, cb)
  M.async("volume " .. cmd, function(ok)
    if ok and cb then cb() end
  end)
end

return M
