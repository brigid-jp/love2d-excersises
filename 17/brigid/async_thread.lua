-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local function new(thread_id, recv_channel)
  local thread = love.thread.newThread "brigid/async_thread_impl.lua"
  local send_channel = love.thread.newChannel()
  local intr_channel = love.thread.newChannel()

  thread:start(thread_id, recv_channel, send_channel, intr_channel)

  return {
    thread_id = thread_id;
    thread = thread;
    send_channel = send_channel;
    intr_channel = intr_channel;
    status = "idle";
  }
end

local class = {}
local metatable = { __index = class }

function class:quit()
  return self.send_channel:push { "quit" }
end

function class:wait()
  self.thread:wait()
end

function class:run_task(task)
  self.status = "active"
  self.task = task
  task.status = "running"
  task.thread = self
  self.send_channel:push { "task", unpack(task) }
end

function class:cancel_task()
  self.intr_channel:push { "cancel" }
end

function class:complete_task(status, ...)
  local task = self.task
  self.status = "inactive"
  self.task = nil
  task.status = status
  task.thread = nil
  task.result = { ... }
  return task
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
