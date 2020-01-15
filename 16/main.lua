-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local b = {
  async_service = require "brigid.async_service";
}

local g = love.graphics

local async_service

function love.load()
  async_service = b.async_service(2)
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

local id = 0

function love.keyreleased(key)
  print("keyreleased", key)
  id = id + 1
  if key == "s" then
    async_service:push("sleep", 2)
  end
end
