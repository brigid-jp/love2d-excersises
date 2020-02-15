-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
}

local unpack = table.unpack or unpack

local function new(service, task_id, ...)
  return {
    service = service;
    task_id = task_id;
    action = { ... };
    status = "pending";
  }
end

local class = {}
local metatable = { __index = class }

function class:cancel()
  local status = self.status
  if status == "pending" then
    self.service:cancel(self)
    self:set_ready("failure", "canceled")
  elseif status == "running" then
    self.thread:cancel()
  end
end

function class:run(thread)
  local action = self.action

  self.action = nil
  self.status = "running"
  self.thread = thread

  return action
end

function class:set_progress(...)
  self.progress = { ... }
end

function class:set_ready(status, ...)
  local caller = self.caller

  self.status = status
  self.thread = nil
  self.result = { ... }
  self.caller = nil

  self.service:remove_timer(self)

  if caller then
    assert(coroutine.resume(caller, "ready"))
  end
end

function class:set_timeout()
  local caller = self.caller

  self.caller = nil

  if caller then
    assert(coroutine.resume(caller, "timeout"))
  end
end

function class:wait()
  local status = self.status
  if status == "success" or status == "failure" then
    return "ready"
  else
    self.caller = coroutine.running()
    return coroutine.yield()
  end
end

function class:wait_for(timer)
  local status = self.status
  if status == "success" or status == "failure" then
    return "ready"
  else
    self.timer = love.timer.getTime() + timer
    self.service:push_timer(self)
    self.caller = coroutine.running()
    return coroutine.yield()
  end
end

function class:get()
  self:wait()
  local status = self.status
  if status == "success" then
    return unpack(self.result)
  elseif status == "failure" then
    return error(unpack(self.result))
  end
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
