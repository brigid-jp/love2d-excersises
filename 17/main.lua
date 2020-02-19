-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local G = love.graphics
local W = love.window

local async_service = require "brigid.async_service"
local bootloader = require "brigid.bootloader"

local unpack = table.unpack or unpack

local service
local tasks = {}
local n = 0
local coro
local brigid

function love.load()
  service = async_service(4)
  local coro = coroutine.create(function ()
    if bootloader(service) then
      service:restart()
    end
    brigid = require "brigid"
  end)
  assert(coroutine.resume(coro))

  local coro = coroutine.create(function ()
    print "coro start"
    for i = 1, 10 do
      local future = service:sleep(2, 100)
      print("coro waiting", i)
      future:wait()
      print("coro waited", i)
      local v = future:get()
      print(v)
    end
  end)
  -- coroutine.resume(coro)

  local coro = coroutine.create(function ()
    print("coro start")
    local future = service:sleep(3, 100)
    local r = future:wait_for(1)
    print("wait_for(1)", r)
    local r = future:wait_for(1)
    print("wait_for(1)", r)
    local r = future:wait_for(2)
    print("wait_for(1)", r)
    local r = future:get()
    print("get()", r)

    local future = service:sleep(3, 100)
    local r = future:wait_for(1)
    print("wait_for(1)", r)
    future:cancel()
    local r, msg = pcall(function () return future:get() end)
    assert(not r)
    print("get()", msg)
  end)
  -- coroutine.resume(coro)

  -- service:dispatch(function ()
  --   local future = service:sleep(2)
  --   local v = future:get()
  --   print(v)
  -- end)
end

function love.update(dt)
  if service then
    service:update()
  end
end

function love.draw()
  if not service then
    return
  end

  local x, y, w, h = W.getSafeArea()
  local buffer = {}

  buffer[1] = ("thread total %d / queue %d / brigid %s"):format(service.thread_count, service.thread_stack:count(), brigid)
  buffer[2] = love.timer.getFPS() .. " fps"
  for i = 1, n do
    local task = tasks[i]
    local status = task.status
    if status == "failure" then
      status = status .. " (" .. task.result[1] .. ")"
    end
    local progress = task.progress
    if progress then
      progress = ("%.2f%%"):format(progress[1] / progress[2] * 100)
    else
      progress = ""
    end
    buffer[i + 2] = i .. " " .. tostring(task) .. " " .. status .. " " .. progress
  end
  G.printf(table.concat(buffer, "\n"), x + 24, y + 24, w - 48)
end

function love.keyreleased(key)
  if key == "q" then
    print "q"
    service:shutdown()
  elseif key == "r" then
    print "r"
    service:restart()
  elseif key == "s" then
    print "s"
    n = n + 1
    tasks[n] = service:sleep(2, 100)
  elseif key == "t" then
    print "t"
    n = n + 1
    tasks[n] = service:sleep(2, 1)
  elseif key == "c" then
    print "c"
    local task = tasks[n]
    if task then
      task:cancel()
    end
  elseif key == "h" then
    local url = "http://brigid.jp/pub/mplus-TESTFLIGHT-063a/mplus-1mn-light.ttf"
    local filename = "mplus-1mn-light.ttf"
    local size = 1655680
    local sha256 = "\034\128\177\205\031\119\013\144\179\214\072\088\137\142\089\156\238\202\049\011\087\071\004\149\086\050\048\100\162\133\121\058"
    n = n + 1
    tasks[n] = service:download_luasocket(url, filename, size, sha256)
  elseif key == "j" then
    local url = "https://brigid.jp/pub/mplus-TESTFLIGHT-063a/mplus-1mn-light.ttf"
    local filename = "mplus-1mn-light.ttf"
    local size = 1655680
    local sha256 = "\034\128\177\205\031\119\013\144\179\214\072\088\137\142\089\156\238\202\049\011\087\071\004\149\086\050\048\100\162\133\121\058"
    n = n + 1
    tasks[n] = service:download(url, filename, size, sha256)
  end
end
