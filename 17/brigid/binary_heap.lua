-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local function up_heap(self, u, i)
  if i > 1 then
    local j = (i - i % 2) / 2
    local v = self[j]
    if u < v then
      self[i] = v
      self[j] = u
      return up_heap(self, u, j)
    end
  end
end

local function down_heap(self, u, i, j)
  local v = self[j]
  if v then
    local k = j + 1
    local w = self[k]
    if w then
      if w < v then
        j = k
        v = w
      end
    end
    if v < u then
      self[i] = v
      self[j] = u
      return down_heap(self, v, j, j * 2)
    end
  end
end

local class = {}
local metatable = { __index = class }

function class:empty()
  return self.n == 0
end

function class:count()
  return self.n
end

function class:push(u)
  local n = self.n + 1
  self.n = n
  self[n] = u
  up_heap(self, u, n)
end

function class:peek()
  return self[1]
end

function class:pop()
  local u = self[1]
  if u then
    local n = self.n
    local v = self[n]
    self.n = n - 1
    self[1] = v
    self[n] = nil
    down_heap(self, v, 1, 2)
  end
  return u
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({ n = 0 }, metatable)
  end;
})

