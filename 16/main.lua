-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local b = {
  async_service = require "brigid.async_service";
}

local g = love.graphics

local async_service

function love.load()
  async_service = b.async_service(0, 1, 2)
  -- print(async_service.max_threads)
  -- print(async_service.max_spare_threads)
  -- print(async_service.spare_threads)
end

function love.update(dt)
  if async_service then
    async_service:update()
  end
end

function love.draw()
  local x, y, w, h = love.window.getSafeArea()
end

local task

function love.keyreleased(key)
  print("keyreleased", key)
  if key == "s" then
    task = async_service:push("sleep", 2)
  elseif key == "p" then
    if task then
      print(task.status)
      -- async_service:cancel(task)
    end
  elseif key == "c" then
    if task then
      print(task.status)
      async_service:cancel(task)
    end
  end
end
