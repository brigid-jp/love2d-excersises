-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local function new(compare, get_handle, set_handle)
  if not compare then
    compare = function (a, b)
      return a > b
    end
  end

  if not get_handle then
    get_handle = function (a)
      return a
    end
  end

  if not set_handle then
    set_handle = function () end
  end

  return {
    compare = compare;
    get_handle = get_handle;
    set_handle = set_handle;
    heap = {};
    index = {};
    value = {};
    n = 0;
    m = 0;
  }
end

local function up_heap(compare, heap, index, value, i, p, u)
  while i > 1 do
    local j = (i - i % 2) / 2
    local q = heap[j]
    local v = value[q]
    if compare(u, v) then
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

local function down_heap(compare, heap, index, value, i, p, u)
  local result = false
  local j = i * 2
  local q = heap[j]
  while q do
    local v = value[q]
    local k = j + 1
    local r = heap[k]
    if r then
      local w = value[r]
      if compare(w, v) then
        j = k
        q = r
        v = w
      end
    end
    if compare(v, u) then
      heap[i] = q
      heap[j] = p
      index[p] = j
      index[q] = i
      i = j
      j = i * 2
      q = heap[j]
      result = true
    else
      break
    end
  end
  return result
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

  local i = self.n + 1
  local p = self.m + 1

  heap[i] = p
  index[p] = i
  value[p] = u
  self.n = i
  self.m = p

  up_heap(self.compare, heap, index, value, i, p, u)

  self.set_handle(u, p)
  return p
end

function class:peek()
  return self.value[self.heap[1]]
end

function class:pop()
  local heap = self.heap

  local p = heap[1]
  if not p then
    return nil
  end

  local index = self.index
  local value = self.value

  local j = self.n
  local q = heap[j]
  local u = value[p]

  heap[1] = q
  heap[j] = nil
  index[p] = nil
  index[q] = 1
  value[p] = nil
  self.n = j - 1

  down_heap(self.compare, heap, index, value, 1, q, value[q])

  self.set_handle(u, nil)
  return u
end

function class:get(p)
  local p = self.get_handle(p)
  if not p then
    return nil
  end

  return self.value[p]
end

function class:remove(p)
  local p = self.get_handle(p)
  if not p then
    return nil
  end

  local heap = self.heap
  local index = self.index
  local value = self.value

  local i = index[p]
  local j = self.n
  local u = value[p]

  if i == j then
    heap[j] = nil
    index[p] = nil
    value[p] = nil
    self.n = j - 1
  else
    local compare = self.compare

    local q = heap[j]
    local v = value[q]

    heap[i] = q
    heap[j] = nil
    index[p] = nil
    index[q] = i
    value[p] = nil
    self.n = j - 1

    if not down_heap(compare, heap, index, value, i, q, v) then
      up_heap(compare, heap, index, value, i, q, v)
    end
  end

  self.set_handle(u, nil)
  return u
end

function class:update(p, u)
  local p = self.get_handle(p)
  if not p then
    return false
  end

  local compare = self.compare
  local index = self.index
  local value = self.value

  local i = index[p]
  local v = value[p]

  if u == nil then
    local heap = self.heap
    if not down_heap(compare, heap, index, value, i, p, v) then
      up_heap(compare, heap, index, value, i, p, v)
    end
  else
    value[p] = u
    if compare(u, v) then
      up_heap(compare, self.heap, index, value, i, p, u)
    else
      down_heap(compare, self.heap, index, value, i, p, u)
    end
  end

  return true
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
