-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local class = {}
local metatable = { __index = class }

function class:empty()
  return self.m > self.n
end

function class:count()
  return self.n - self.m + 1
end

function class:push(item)
  local m = self.m
  local n = self.n + 1
  self.n = n
  self[n] = item
end

function class:peek()
  return self[self.m]
end

function class:pop()
  local m = self.m
  local n = self.n
  if m > n then
    return
  end
  local item = self[m]
  self.m = m + 1
  self[m] = nil
  return item
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({ m = 1, n = 0 }, metatable)
  end;
})
