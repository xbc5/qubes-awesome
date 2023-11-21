local x = {
  qube = require("x.qube"),
}

return {
  notes = {
    class = "notes:Emacs",
  },
  rofi = {
    class = {
      any = "[rR]ofi$", -- [:^][rR]ofi$ doesn't match "rofi" (i.e. dom0)
    }
  },
  dev_s = {
    class = "^dev[-]s", -- '-' does not match on its own
  }
}
