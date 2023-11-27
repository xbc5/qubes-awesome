local naughty = require("naughty")

local M = {
  preset = {
    low = naughty.config.presets.low,
    normal = naughty.config.presets.normal,
    critical = naughty.config.presets.critical,
  }
}

function M.test(msg)
  naughty.notify({
    preset = naughty.config.presets.normal,
    title = "test",
    text = msg,
  })
end

function M.run_error(msg, log)
  naughty.notify({
    preset = M.preset.critical,
    title = "Run error",
    text = msg,
  })
end

-- When a tag starts its VMs and clients have started.
function M.tag_ready(name)
  naughty.notify({
    preset = M.preset.normal,
    title = name .. " ready",
  })
end

-- When the VMs or clients associated with a tag fail to start
function M.tag_error(name, stderr)
  naughty.notify({
    preset = M.preset.critical,
    title = name .. " error",
    text = stderr,
  })
end

function M.client_error(msg, log)
  naughty.notify({
    preset = M.preset.critical,
    title = "Client error",
    text = msg,
  })
end

return M
