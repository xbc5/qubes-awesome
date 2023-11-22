local x = {
  qube = require("x.qube"),
}

local M = {
  -- qubes
  daily = {
    class = "^daily",
  },
  dev = {
    class = "^dev",
  },
  dev_s = {
    class = "^dev[-]s", -- '-' does not match on its own
  },

  -- apps
  xide = {
    class = "ide$",
  },
  librewolf = {
    class = "librewolf[-].+$"  -- librewolf includes the profile name
  },
  matrix_client = {
    class = "matrix:librewolf-default",
  },
  notes = {
    class = "notes:Emacs",
  },
  rofi = {
    class = {
      any = "[rR]ofi$", -- [:^][rR]ofi$ doesn't match "rofi" (i.e. dom0)
    }
  },
}


function M.join(qube, app)
  return qube .. ":" .. app
end

function M.browser(qube)
  local c = M.librewolf.class
  return { class = { M.join(qube, c) } }
end

function M.ide(qube)
  local c = M.xide.class
  return { class = { M.join(qube, c) } }
end

return M
