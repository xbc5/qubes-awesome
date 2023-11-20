local M = {}

-- Shallow copy a table.
-- @param t A table.
-- @return A new table.
function M.shallow_copy(t)
  local nt = {}
  for k, v in pairs(t) do nt[k] = v end
  return nt
end

return M
