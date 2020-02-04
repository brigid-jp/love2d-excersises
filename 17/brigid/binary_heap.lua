-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

-- handle to index
-- index to handle

-- m handle generator
-- n size of heap

--[[

map[h] = v

heap[i] = h
peah[h] = i


heap[i] = v
htoi[h] = i
itoh[i] = h


heap[i] = p
value_table[p] = v
index_table[p] = i

values
indices

heap[i] = p
deref
*p == v
indexof(p)

htov[h] = v
htoi[h] = i



]]

local function up_heap(heap, index, value, i, x, u)
  while i > 1 do
    local j = (i - i % 2) / 2
    local y = heap[j]
    local v = value[y]
    if u < v then
      heap[i] = y
      heap[j] = x
      index[x] = j
      index[y] = i
      i = j
    else
      break
    end
  end
end

local function down_heap(heap, index, value, i, x, u)
  local j = i * 2
  local y = heap[j]
  while y do
    local v = value[y]
    local k = j + 1
    local z = heap[k]
    if z then
      local w = value[z]
      if w < v then
        j = k
        y = z
        v = w
      end
    end
    if v < u then
      heap[i] = y
      heap[j] = x
      index[x] = j
      index[y] = i
      i = j
      j = j * 2
      y = heap[j]
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
  local x = heap[1]
  if x then
    local index = self.index
    local value = self.value

    local n = self.n
    local y = heap[n]

    heap[1] = y
    heap[n] = nil
    index[y] = 1
    index[x] = nil

    local u = value[x]
    value[x] = nil

    self.n = n - 1

    down_heap(heap, index, value, 1, y, value[y])
    return u
  end
  return u
end

return setmetatable(class, {
  __call = function ()
    return setmetatable({ heap = {}, index = {}, value = {}, m = 0, n = 0 }, metatable)
  end;
})

