-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local function up_heap(self, u, i)
  while i > 1 do
    local j = (i - i % 2) / 2
    local v = self[j]
    if u < v then
      self[i] = v
      self[j] = u
      i = j
    else
      break
    end
  end
end

local function down_heap(self, u, i)
  local j = i * 2
  local v = self[j]
  while v do
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
      i = j
      j = j * 2
      v = self[j]
    else
      break
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
    local u = self[n]
    self.n = n - 1
    self[1] = u
    self[n] = nil
    down_heap(self, u, 1)
  end
  return u
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({ n = 0 }, metatable)
  end;
})

