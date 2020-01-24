-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
}
local async = require "brigid.async"

local thread_id, send_channel, recv_channel, intr_channel = ...

local async_promise = (function ()
  local function new(thread_id, send_channel, intr_channel)
    return {
      thread_id = thread_id;
      send_channel = send_channel;
      intr_channel = intr_channel;
    }
  end

  local class = {}
  local metatable = { __index = class }

  function class:progress(progress)
    send_channel:push { "progress", thread_id, progress }
  end

  function class:success(...)
    send_channel:push { "success", thread_id, ... }
  end

  function class:failure(...)
    send_channel:push { "failure", thread_id, ... }
  end

  function class:canceled()
    local intr_channel = self.intr_channel
    local result = false
    while true do
      local message = intr_channel:pop()
      if not message then
        break
      end
      result = true
    end
    return result
  end

  return setmetatable(class, {
    __call = function (_, ...)
      return setmetatable(new(...), metatable)
    end;
  })
end)()

while true do
  local message = recv_channel:demand()
  local method = message[1]
  if method == "quit" then
    break
  elseif method == "task" then
    local task = message[2]
    local promise = async_promise(thread_id, send_channel, intr_channel)

    if task == "sleep" then
      local s = message[3]
      local result, message = pcall(function ()
        local n = 10
        promise:progress(0, n)
        for i = 1, n do
          if promise:canceled() then
            error "canceled"
          end
          love.timer.sleep(s / n)
          promise:progress(i, n)
        end
        return 42
      end)

      if result then
        promise:success(message)
      else
        promise:failure(message)
      end
    end
  end
end

send_channel:push { "quit", thread_id }
