-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

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

local heap = binary_heap()

heap:push(5)
heap:push(11)
heap:push(8)
heap:push(3)
heap:push(4)
heap:push(15)
dump(heap)

print "===="
print(heap:pop())
dump(heap)
print "===="
print(heap:pop())
dump(heap)
print "===="
print(heap:pop())
dump(heap)

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
timer:stop()
print("seq", timer:elapsed())
