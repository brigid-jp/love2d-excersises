-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local G = love.graphics
local W = love.window

local async = require "brigid.async"

local service
local f

function love.load()
  service = async.service(1)

  service:dispatch(function ()
    local f1 = service:sleep(2)
    assert(f1:get())

    local f2 = service:sleep(2)
    assert(f2:get())

    local f3 = service:sleep(2)
    local f4 = service:sleep(4)
    local f5 = service:sleep(5)

    async.wait_all(f3, f4, f5)
    assert(f3:get())
    assert(f4:get())
    assert(f5:get())
    assert(f6:get())
  end)

  service:dispatch(function ()
    while true do
      local f = service:wait()
      assert(f:get())
    end
  end)
end

function love.update(dt)
  service:update()
end

function love.draw()
  local x, y, w, h = W.getSafeArea()
end

local f

function love.keyreleased(key)
  if key == "q" then
    print "q"
    service:test1()
  elseif key == "s" then
    print "s"
    f = service:sleep(2)
  elseif key == "t" then
    print "t"
    f = service:sleep2(2)
  elseif key == "c" then
    print "c"
    if f then
      f:cancel()
    end
  end
end
