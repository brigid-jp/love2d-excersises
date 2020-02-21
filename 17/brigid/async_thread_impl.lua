-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local async_promise = require "brigid.async_promise"
local async_tasks = require "brigid.async_tasks"

local unpack = table.unpack or unpack

local task_table  = {}
for i = 1, #async_tasks do
  local task = async_tasks[i]
  pcall(function ()
    local module = require("brigid.async_task." .. task)
    task_table[task] = module
  end)
end

local thread_id, send_channel, intr_channel, recv_channel = ...

while true do
  local message = recv_channel:demand()
  if message == "close" then
    break
  else
    local promise = async_promise(thread_id, intr_channel, send_channel)
    local task = task_table[message[1]]
    if task then
      promise:set_ready(pcall(task, promise, unpack(message, 2)))
    else
      promise:set_ready(false, "task not found")
    end
  end
end

send_channel:push { "closed", thread_id }
