-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local b = {
  thread_pool = require "brigid.thread_pool";
}

local g = love.graphics

local thread_pool

function love.load()
  thread_pool = b.thread_pool(2)
  -- print(thread_pool.max_threads)
  -- print(thread_pool.max_spare_threads)
  -- print(thread_pool.spare_threads)
end

function love.update(dt)
end

function love.draw()
  local x, y, w, h = love.window.getSafeArea()
end

function love.keyreleased(key)
  print("keyreleased", key)
  if key == "q" then
    thread_pool:stop_all()
  elseif key == "s" then
    thread_pool:sleep(1, 1)
  elseif key == "t" then
    thread_pool:sleep(2, 1)
  elseif key == "w" then
    thread_pool:wait_all()
  end
end
