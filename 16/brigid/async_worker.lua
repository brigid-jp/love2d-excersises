-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
  thread = require "love.thread";
}

local unpack = table.unpack or unpack

local worker_id, recv_channel, send_channel, task_channel = ...

local function task_sleep(task_id, s)
  local n = 10
  for i = 1, n do
    local recv = task_channel:pop()
    if recv then
      -- cancel
      error "canceled"
    end
    love.timer.sleep(s / n)
    send_channel:push { "progress", worker_id, task_id, i, n }
  end
end

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
        local result, message = pcall(task_sleep, task_id, recv[4])
        if result then
          send_channel:push { "success", worker_id, task_id }
        else
          send_channel:push { "failure", worker_id, task_id, message }
        end
        print("slept", "worker_id:" .. worker_id, "task_id:" .. task_id)
      end
    end
  end
end

send_channel:push { "quit", worker_id }
