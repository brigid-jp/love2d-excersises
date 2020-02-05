-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local binary_heap = require "brigid.binary_heap"

local verbose = os.getenv "VERBOSE" == "1"

local function check(source, expect)
  local P = {}
  local U = {}
  for i = 1, source.n do
    local p = source.heap[i]
    P[i] = p
    U[i] = source.value[p]
  end

  local n_index = 0
  for _ in pairs(source.index) do
    n_index = n_index + 1
  end

  local n_value = 0
  for _ in pairs(source.value) do
    n_value = n_value + 1
  end

  if verbose then
    io.write("# ", #P, " ", #U, " ", n_index, " ", n_value, "\n")
    io.write "P"
    for i = 1, #P do
      io.write(" ", P[i])
    end
    io.write "\n"

    io.write "U"
    for i = 1, #U do
      io.write(" {", U[i][1], ",", U[i][2], "}")
    end
    io.write "\n"
  end

  assert(#U == #expect)
  assert(#U == #P)
  assert(#U == n_index)
  assert(#U == n_value)
  for i = 1, #expect do
    assert(U[i][1] == expect[i][1])
    assert(U[i][2] == expect[i][2])
  end
end

local item
do
  local class = {}
  local metatable = { __index = class }

  function class:eq(x, y)
    return self[1] == x and self[2] == y
  end

  function metatable.__lt(a, b)
    return a[2] > b[2]
  end

  item = function (...)
    return setmetatable({ ... },  metatable)
  end
end

local x = binary_heap()
x:push(item(5, 1))
check(x, { { 5, 1 } })
x:push(item(4, 2))
check(x, { { 4, 2 }, { 5, 1 } })
x:push(item(3, 3))
check(x, { { 3, 3 }, { 5, 1 }, { 4, 2 } })
x:push(item(2, 4))
check(x, { { 2, 4 }, { 3, 3 }, { 4, 2 }, { 5, 1 } })
x:push(item(1, 5))
check(x, { { 1, 5 }, { 2, 4 }, { 4, 2 }, { 5, 1 }, { 3, 3 } })

assert(x:pop():eq(1, 5))
assert(x:pop():eq(2, 4))
assert(x:pop():eq(3, 3))
assert(x:pop():eq(4, 2))
assert(x:pop():eq(5, 1))

local x = binary_heap()
local h1 = x:push(item(1, 100))
local h2 = x:push(item(2, 200))
local h3 = x:push(item(3, 300))
local h4 = x:push(item(4, 400))
local h5 = x:push(item(5, 500))
check(x, { { 5, 500 }, { 4, 400 }, { 2, 200 }, { 1, 100 }, { 3, 300 } })

assert(x:remove(h3):eq(3, 300))
check(x, { { 5, 500 }, { 4, 400 }, { 2, 200 }, { 1, 100 } })

local h6 = x:push(item(6, 600))
local h7 = x:push(item(7, 700))
check(x, { { 7, 700 }, { 5, 500 }, { 6, 600 }, { 1, 100 }, { 4, 400 }, { 2, 200 } })

assert(x:remove(h5):eq(5, 500))
check(x, { { 7, 700 }, { 4, 400 }, { 6, 600 }, { 1, 100 }, { 2, 200 } })

local h5 = x:push(item(5, 500))
check(x, { { 7, 700 }, { 4, 400 }, { 6, 600 }, { 1, 100 }, { 2, 200 }, { 5, 500 } })

assert(x:remove(h2):eq(2, 200))
check(x, { { 7, 700 }, { 5, 500 }, { 6, 600 }, { 1, 100 }, { 4, 400 } })

x:update(h5, item(5, 0))
check(x, { { 7, 700 }, { 4, 400 }, { 6, 600 }, { 1, 100 }, { 5, 0 } })

x:update(h1, item(1, 1000))
check(x, { { 1, 1000 }, { 7, 700 }, { 6, 600 }, { 4, 400 }, { 5, 0 } })

local x = binary_heap()
x:push(1)
assert(not x:empty())
assert(x:count() == 1)
assert(x:pop() == 1)
assert(x:empty())
assert(x:count() == 0)
assert(x:pop() == nil)
assert(x:empty())
assert(x:count() == 0)
