-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

-- local binary_heap = require "brigid.binary_heap_pure"
local binary_heap = require "brigid.binary_heap"
local unix = require "dromozoa.unix"

local function dump(heap)
  io.write "----\n"
  local n = #heap
  local m = 1
  local w = 1
  while m <= n do
    for i = m, math.min(m + w - 1, n) do
      if i > m then
        io.write " "
      end
      io.write(heap[i])
    end
    m = m + w
    w = w * 2
    io.write "\n"
  end
end

local function dump(self)
  io.write "----\n"
  local heap = self.heap
  local value = self.value

  local n = #heap
  local m = 1
  local w = 1
  while m <= n do
    for i = m, math.min(m + w - 1, n) do
      if i > m then
        io.write " "
      end
      io.write("[", heap[i], "]=", value[heap[i]])
    end
    m = m + w
    w = w * 2
    io.write "\n"
  end
end

local unpack = table.unpack or unpack

local function check(...)
  -- print("<", ...)
  local source = { ... }
  local expect = { ... }
  table.sort(expect)
  -- print("?", unpack(expect))

  local heap = binary_heap()
  for i = 1, #source do
    heap:push(i)
  end

  -- dump(heap)

  local n = 0
  while true do
    local v = heap:pop()
    if not v then
      break
    end
    n = n + 1
    -- print("!", v, expect[n])
    assert(v == expect[n])

    -- dump(heap)

  end
  assert(n == #expect)
end

local function perm(m, n, result, ...)
  local t = { ... }
  if m == 0 then
    result[#result + 1] = t
  else
    local j = #t
    local f = {}
    for i = 1, j do
      f[t[i]] = true
    end

    local j = j + 1
    m = m - 1
    for i = 1, n do
      if not f[i] then
        t[j] = i
        perm(m, n, result, unpack(t))
      end
    end
  end
end

local timer = unix.timer()

if os.getenv "TEST" == "1" then
  print "test started"
  timer:start()
  for i = 3, 8 do
    local result = {}
    perm(i, i, result)
    for i = 1, #result do
      check(unpack(result[i]))
    end
  end
  timer:stop()
  print "test finished"
  print("test", timer:elapsed())
end

do
  local function check(heap, expect)
    local n = 0
    while true do
      local v = heap:pop()
      if not v then
        break
      end
      n = n + 1
      assert(v == expect[n])
    end
    assert(n == #expect)
  end

  local v = { 5, 11, 8, 3, 4, 15 }

  for i = 1, 6 do
    local heap = binary_heap()
    local h = {}

    h[1] = heap:push(v[1])
    h[2] = heap:push(v[2])
    h[3] = heap:push(v[3])
    h[4] = heap:push(v[4])
    h[5] = heap:push(v[5])
    h[6] = heap:push(v[6])
    -- dump(heap)
    -- print("REMOVE [" .. h[i] .. "]=" .. v[i])
    local removed = heap:remove(h[i])
    assert(removed == v[i])
    -- dump(heap)

    local t = {}
    for j = 1, 6 do
      if i ~= j then
        t[#t + 1] = v[j]
      end
    end
    table.sort(t)
    check(heap, t)
  end
end

local heap = binary_heap()

timer:start()
for i = 1, 1000000 do
  heap:push(i)
end
timer:stop()
print("push", timer:elapsed())

timer:start()
for i = 1, 1000000 do
  heap:pop()
end
timer:stop()
print("pop", timer:elapsed())

timer:start()
for i = 1000000, 1, -1 do
  heap:push(i)
end
timer:stop()
print("push", timer:elapsed())

timer:start()
for i = 1, 1000000 do
  heap:pop()
end
timer:stop()
print("pop", timer:elapsed())

local t = {}
timer:start()
for i = 1000000, 1, -1 do
  t[#t + 1] = i
end
table.sort(t, function (a, b) return a > b end)
timer:stop()
print("seq", timer:elapsed())
