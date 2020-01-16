-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
  thread = require "love.thread";
}

local unpack = table.unpack or unpack

local worker_id, recv_channel, send_channel, intr_channel = ...

local function task_sleep(task_id, s)
  local n = 10
  for i = 1, n do
    local msg = intr_channel:pop()
    if msg then
      error "canceled"
    end
    love.timer.sleep(s / n)
    send_channel:push {
      worker_id = worker_id;
      task_id = task_id;
      "progress", i, n;
    }
  end
  return 42
end

while true do
  local msg = recv_channel:demand()
  if msg then
    local method = msg[1]
    if method == "quit" then
      break
    elseif method == "task" then
      local task_id = msg.task_id
      local command = msg[2]
      if command == "sleep" then
        print(worker_id, task_id)
        print(("[sleep start] worker_id:%d task_id:%d"):format(worker_id, task_id))
        local result = {
          worker_id = worker_id;
          task_id = task_id;
          pcall(task_sleep, task_id, msg[3]);
        }
        print(("[sleep done] worker_id:%d task_id:%d"):format(worker_id, task_id))
        if result[1] then
          result[1] = "success"
        else
          result[1] = "failure"
        end
        send_channel:push(result)
      end
    end
  end
end

send_channel:push {
  worker_id = worker_id;
  "quit";
}
