-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local class = {}
local metatable = { __index = class }

function class:empty()
  return self.n == 0
end

function class:count()
  return self.n
end

function class:push(item)
  local n = self.n + 1
  self.n = n
  self[n] = item
end

function class:peek()
  return self[self.n]
end

function class:pop()
  local n = self.n
  if n == 0 then
    return nil
  end
  local item = self[n]
  self.n = n - 1
  self[n] = nil
  return item
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({ m = 1, n = 0 }, metatable)
  end;
})
