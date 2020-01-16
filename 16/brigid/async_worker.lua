-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
  thread = require "love.thread";
}

local unpack = table.unpack or unpack

local worker_id, recv_channel, send_channel = ...

while true do
  local recv = recv_channel:demand()
  if recv then
    local req = recv[1]
    if req == "quit" then
      break
    elseif req == "task" then
      -- task block
      local task_id = recv[2]
      local command = recv[3]
      if command == "sleep" then
        print("sleeping", "worker_id:" .. worker_id, "task_id:" .. task_id)
        love.timer.sleep(recv[4])
        print("slept", "worker_id:" .. worker_id, "task_id:" .. task_id)
      end
      send_channel:push { "success", worker_id, task_id }
    end
  end
end

send_channel:push { "quit", worker_id }
