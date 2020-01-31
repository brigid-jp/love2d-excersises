-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local class = {}
local metatable = { __index = class }

local unpack = table.unpack or unpack

function class:cancel()
  local status = self.status
  if status == "pending" then
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

  local caller = self.caller
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
    return setmetatable({ action = { ... }, status = "pending" }, metatable)
  end;
})
