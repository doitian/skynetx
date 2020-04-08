--- xi namespace.
--
-- 访问 xi.NAME 会自动去加载 "xi/NAME.lua"
--
-- @module xi
local xi = {}

local function __index(t, k)
  assert(type(k) == "string" and k ~= "")
  local m = require("xi." .. k)
  t[k] = m
  return m
end

return setmetatable(xi, {__index = __index})
