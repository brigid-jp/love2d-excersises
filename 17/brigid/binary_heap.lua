-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local function up_heap(self, u, i)
  while i > 1 do
    local j = (i - i % 2) / 2
    local v = self[j]
    if v < u then
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
      if v < w then
        j = k
        v = w
      end
    end

    if u < v then
      self[i] = v
      self[j] = u
      i = j
      j = i * 2
      v = u
    else
      break
    end
  end
end

local class = {}
local metatable = { __index = class }

function class:push(u)
  local i = #self + 1
  self[i] = u
  up_heap(self, u, i)
end

function class:pop()
  local u = self[1]
  if u then
    local i = #self
    local v = self[i]
    self[1] = v
    self[i] = nil
    down_heap(self, v, 1)
  end
  return u
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({}, metatable)
  end;
})

