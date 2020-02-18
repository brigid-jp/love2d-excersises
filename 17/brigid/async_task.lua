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

local function resume(self, ...)
  local caller = self.caller
  self.caller = nil
  if caller then
    local result, message = coroutine.resume(caller, ...)
    if not result then
      error(message)
    end
  end
end

local class = {}
local metatable = { __index = class }

function class:cancel()
  local status = self.status
  if status == "pending" then
    local service = self.service
    service.pending_tasks:remove(self)
    service.waiting_tasks:remove(self)
    self:set_ready("failure", "canceled")
  elseif status == "running" then
    self.thread:cancel()
  end
end

function class:run(thread)
  self.status = "running"
  self.thread = thread
end

function class:set_progress(...)
  self.progress = { ... }
end

function class:set_ready(status, ...)
  self.status = status
  self.thread = nil
  self.result = { ... }
  self.service.waiting_tasks:remove(self)
  resume(self, "ready")
end

function class:set_timeout()
  resume(self, "timeout")
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

function class:wait_for(timeout)
  local status = self.status
  if status == "success" or status == "failure" then
    return "ready"
  else
    self.timeout = love.timer.getTime() + timeout
    self.service.waiting_tasks:push(self)
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
