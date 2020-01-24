-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local class = {}
local metatable = { __index = class }

function class:cancel()
  local status = self.status
  if status == "pending" then
    self.status = "failure"
    self.result = { "canceled" }
  elseif status == "running" then
    self.thread:cancel_task()
  end
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable({ status = "pending", ... }, metatable)
  end;
})

