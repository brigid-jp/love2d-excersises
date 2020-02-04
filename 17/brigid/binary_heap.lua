-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local function up_heap(heap, index, value, i, p, u)
  while i > 1 do
    local j = (i - i % 2) / 2
    local q = heap[j]
    local v = value[q]
    if u < v then
      heap[i] = q
      heap[j] = p
      index[p] = j
      index[q] = i
      i = j
    else
      break
    end
  end
end

local function down_heap(heap, index, value, i, p, u)
  local result
  local j = i * 2
  local q = heap[j]
  while q do
    local v = value[q]
    local k = j + 1
    local z = heap[k]
    if z then
      local w = value[z]
      if w < v then
        j = k
        q = z
        v = w
      end
    end
    if v < u then
      result = true
      heap[i] = q
      heap[j] = p
      index[p] = j
      index[q] = i
      i = j
      j = i * 2
      q = heap[j]
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
  local heap = self.heap
  local index = self.index
  local value = self.value
  local m = self.m + 1
  local n = self.n + 1

  heap[n] = m
  index[m] = n
  value[m] = u
  self.m = m
  self.n = n

  up_heap(heap, index, value, n, m, u)

  return m
end

function class:peek()
  return self.value[self.heap[1]]
end

function class:pop()
  local heap = self.heap
  local p = heap[1]
  if p then
    local index = self.index
    local value = self.value
    local n = self.n

    local q = heap[n]
    local u = value[p]

    heap[1] = q
    heap[n] = nil
    index[p] = nil
    index[q] = 1
    value[p] = nil
    self.n = n - 1

    down_heap(heap, index, value, 1, q, value[q])

    return u
  else
    return nil
  end
end

function class:remove(p)
  local heap = self.heap
  local index = self.index
  local value = self.value

  local u = value[p]

  local i = index[p]
  local j = self.n
  self.n = j - 1

  if i == j then
    heap[i] = nil
    index[p] = nil
    value[p] = nil
    return u
  else
    local q = heap[j]
    local v = value[q]

    heap[i] = q
    heap[j] = nil
    index[p] = nil
    index[q] = i
    value[p] = nil

    if not down_heap(heap, index, value, i, q, v) then
      up_heap(heap, index, value, i, q, v)
    end
  end
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({ heap = {}, index = {}, value = {}, m = 0, n = 0 }, metatable)
  end;
})

