local menubar = require("menubar")

M = {}

function M.terminal()
  menubar.utils.terminal = "kitty" -- TODO use ENV; remember: login shell ENV works differently
  return "kitty"
end

return M
