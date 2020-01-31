-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local G = love.graphics
local W = love.window

local async_service = require "brigid.async_service"

local service
local tasks = {}
local n = 0

function love.load()
  service = async_service(0, 4, 2)
end

function love.update(dt)
  service:update()
end

function love.draw()
  local x, y, w, h = W.getSafeArea()
  local buffer = {}

  buffer[1] = ("thread total %d / queue %d"):format(service.thread_count, service.thread_queue:count())
  for i = 1, n do
    local task = tasks[i]
    local progress = task.progress
    if progress then
      progress = ("%.2f%%"):format(progress[1] / progress[2] * 100)
    else
      progress = ""
    end
    buffer[i + 1] = i .. " " .. tostring(task) .. " " .. task.status .. " " .. progress
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
