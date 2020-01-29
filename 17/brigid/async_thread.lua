-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local function new(thread_id, recv_channel)
  local thread = love.thread.newThread "brigid/async_thread_impl.lua"
  local intr_channel = love.thread.newChannel()
  local send_channel = love.thread.newChannel()

  thread:start(thread_id, recv_channel, intr_channel, send_channel)

  return {
    thread_id = thread_id;
    thread = thread;
    intr_channel = intr_channel;
    send_channel = send_channel;
    status = "idle";
  }
end

local class = {}
local metatable = { __index = class }

function class:cancel()
  self.intr_channel:push { "cancel" }
end

function class:run(task)
  task:run(self)

  self.status = "active"
  self.task = task
  self.intr_channel:clear()
  self.send_channel:push { "task", unpack(task) }
end

function class:complete(...)
  local task = self.task

  self.status = "idle"
  self.task = nil

  task:complete(...)
end

function class:close()
  self.send_channel:push { "close" }
end

function class:wait()
  self.thread:wait()
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
