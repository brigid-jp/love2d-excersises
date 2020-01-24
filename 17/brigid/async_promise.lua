-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local function new(thread_id, send_channel, intr_channel)
  return {
    thread_id = thread_id;
    send_channel = send_channel;
    intr_channel = intr_channel;
  }
end

local class = {}
local metatable = { __index = class }

function class:progress(...)
  self.send_channel:push { "progress", self.thread_id, ... }
end

function class:success(...)
  self.send_channel:push { "success", self.thread_id, ... }
end

function class:failure(...)
  self.send_channel:push { "failure", self.thread_id, ... }
end

function class:check_canceled()
  local intr_channel = self.intr_channel
  local result = false
  while true do
    local message = intr_channel:pop()
    if not message then
      break
    end
    result = true
  end
  return result
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
