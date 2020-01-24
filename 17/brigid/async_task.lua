-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local class = {}
local metatable = { __index = class }

function class:cancel()
  local status = self.status
  if status == "pending" then
    self:complete("failure", "canceled")
  elseif status == "running" then
    self.thread:cancel()
  end
end

function class:run(thread)
  self.status = "running"
  self.thread = thread
end

function class:complete(status, ...)
  self.status = status
  self.thread = nil
  self.result = { ... }
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable({ status = "pending", ... }, metatable)
  end;
})

