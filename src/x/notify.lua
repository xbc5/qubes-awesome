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

return M
