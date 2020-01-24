-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
}
local async_promise = require "brigid.async_promise"

local thread_id, send_channel, recv_channel, intr_channel = ...

while true do
  local message = recv_channel:demand()
  local method = message[1]
  if method == "close" then
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
          if promise:check_canceled() then
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

send_channel:push { "closed", thread_id }
