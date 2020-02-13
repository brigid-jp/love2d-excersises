-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local unpack = table.unpack or unpack

-- service     : service
-- task_id     : identifier
-- action      : {}
-- status      : "..."
-- task_handle : handle
--
-- thread      : thread
-- result      : {}
-- caller      : coroutine

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
  self.service:cancel(self)
end

function class:run(thread)
  self.status = "running"
  self.thread = thread
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

  if caller then
    assert(coroutine.resume(self.caller, "ready"))
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
