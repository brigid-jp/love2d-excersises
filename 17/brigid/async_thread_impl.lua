-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
}
local async_promise = require "brigid.async_promise"

local tasks = {
  check_file = require "brigid.async_task.check_file";
  luasocket_download = require "brigid.async_task.luasocket_download";
  sleep = require "brigid.async_task.sleep"
}

local thread_id, send_channel, intr_channel, recv_channel = ...

while true do
  local message = recv_channel:demand()
  if message == "close" then
    break
  else
    local promise = async_promise(thread_id, intr_channel, send_channel)
    local task = tasks[message[1]]
    if task then
      promise:dispatch(task, promise, unpack(message, 2))
    else
      promise:set_ready(false, "not found")
    end
  end
end

send_channel:push { "closed", thread_id }
