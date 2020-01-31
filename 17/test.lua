-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local binary_heap = require "brigid.binary_heap"

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
print(heap:pop())
dump(heap)
