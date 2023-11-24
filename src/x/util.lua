local x = { notify = require("x.notify") }

local M = {}

-- Shallow copy a table.
-- @param t A table.
-- @return A new table.
function M.shallow_copy(t)
  local nt = {}
  for k, v in pairs(t) do nt[k] = v end
  return nt
end

-- Iterate over a table, and pass each k,v,t into fn.
-- Return the value you wish to use, and nil to remove it.
-- Be careful if modifying t, it's not safe.
-- @param t A table
-- @param fn The mapper function: fn(v, k, t) => v|nil; v:value, k:key, t:table.
function M.map(t, fn)
  local nt = {}
  for k, v in pairs(t) do
    v = fn(v, k, t)
    if v ~= nil then nt[k] = v end
  end
  return nt
end

function M.filter(t, fn)
  local nt = {}
  for k, v in pairs(t) do
    x.notify.test(v.scratch)
    v = fn(v, k)
    if v == true then nt[k] = v end
  end
  return nt
end

-- Get all clients that have a particular key set to value.
-- @param key The key -- e.g. modal; class.
-- @param value -- e.g. true, "dev:firefox"
function M.get_clients(key, value)
  x.notify.test("getting ")
  return M.filter(client.get(), function(c) return c[key] == value end)
end

return M
