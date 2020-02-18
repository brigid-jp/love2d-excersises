-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
}
local async_promise = require "brigid.async_promise"

local tasks = {
  luasocket_download = require "brigid.luasocket_download";
}

local thread_id, send_channel, intr_channel, recv_channel = ...

while true do
  local message = recv_channel:demand()
  if message == "close" then
    break
  else
    local action = message[1]
    local promise = async_promise(thread_id, intr_channel, send_channel)
    if action == "sleep" then
      promise:dispatch(function (s)
        local n = 100
        promise:set_progress(0, n)
        for i = 1, n do
          if promise:check_canceled() then
            error "canceled"
          end
          love.timer.sleep(s / n)
          promise:set_progress(i, n)
        end
        return 42
      end, message[2])
    elseif action == "sleep2" then
      promise:dispatch(function (s)
        love.timer.sleep(s)
        return 69
      end, message[2])
    else
      local task = tasks[action]
      if task then
        promise:dispatch(task, promise, unpack(message, 2))
      end
    end
  end
end

send_channel:push { "closed", thread_id }
