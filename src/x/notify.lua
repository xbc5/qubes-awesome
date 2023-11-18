local naughty = require("naughty")

local M = {}

function M.test(msg)
  naughty.notify({
    preset = naughty.config.presets.normal,
    title = "test",
    text = msg,
  })
end

return M
