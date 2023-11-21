return {
  notes = {
    class = "notes:Emacs",
  },
  rofi = {
    class = {
      any = "[rR]ofi$", -- [:^][rR]ofi$ doesn't match "rofi" (i.e. dom0)
    }
  },
}
