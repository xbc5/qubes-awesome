local x = {
  qube = require("x.qube"),
}

local M = {
  -- qubes
  daily = {
    class_p = "^daily",
  },
  dev = {
    class_p = "^dev",
  },
  dev_s = {
    class_p = "^dev[-]s", -- '-' does not match on its own
  },

  -- apps
  xide = {
    class_p = "ide$",
  },
  librewolf = {
    class_p = "librewolf[-].+$"  -- librewolf includes the profile name
  },
  matrix_c = {
    class = "matrix:librewolf-default",
  },
  notes = {
    class = "notes:Emacs",
  },
  rofi = {
    class_p = "[rR]ofi$", -- [:^][rR]ofi$ doesn't match "rofi" (i.e. dom0)
  },
}


function M.join(qube, app)
  return qube .. ":" .. app
end

function M.browser(qube)
  local c = M.librewolf.class_p
  return { class = { M.join(qube, c) } }
end

function M.ide(qube)
  local c = M.xide.class_p
  return { class = { M.join(qube, c) } }
end

return M
