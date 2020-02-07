-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local G = love.graphics
local W = love.window

local async_service = require "brigid.async_service"

local service
local tasks = {}
local n = 0
local coro

function love.load()
  service = async_service(0, 4, 2)

  local coro = coroutine.create(function ()
    print "coro start"
    for i = 1, 10 do
      local future = service:sleep(2)
      print("coro waiting", i)
      future:wait()
      print("coro waited", i)
      local v = future:get()
      print(v)
    end
  end)
  -- coroutine.resume(coro)

  -- service:dispatch(function ()
  --   local future = service:sleep(2)
  --   local v = future:get()
  --   print(v)
  -- end)
end

function love.update(dt)
  service:update()
end

function love.draw()
  local x, y, w, h = W.getSafeArea()
  local buffer = {}

  buffer[1] = ("thread total %d / queue %d"):format(service.thread_count, service.thread_queue:count())
  buffer[2] = love.timer.getFPS() .. " fps"
  for i = 1, n do
    local task = tasks[i]
    local progress = task.progress
    if progress then
      progress = ("%.2f%%"):format(progress[1] / progress[2] * 100)
    else
      progress = ""
    end
    buffer[i + 2] = i .. " " .. tostring(task) .. " " .. task.status .. " " .. progress
  end
  G.printf(table.concat(buffer, "\n"), x + 24, y + 24, w - 48)
end

function love.keyreleased(key)
  if key == "q" then
    print "q"
    service:test1()
  elseif key == "s" then
    print "s"
    n = n + 1
    tasks[n] = service:sleep(2)
  elseif key == "t" then
    print "t"
    n = n + 1
    tasks[n] = service:sleep2(2)
  elseif key == "c" then
    print "c"
    local task = tasks[n]
    if task then
      task:cancel()
    end
  end
end
