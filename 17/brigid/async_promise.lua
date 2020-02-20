-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local function new(thread_id, intr_channel, send_channel)
  return {
    thread_id = thread_id;
    intr_channel = intr_channel;
    send_channel = send_channel;
  }
end

local class = {}
local metatable = { __index = class }
local runtime_assertion_metatable = {}

function class:set_progress(...)
  self.send_channel:push { "progress", self.thread_id, ... }
end

function class:set_ready(result, ...)
  if result then
    self.send_channel:push { "success", self.thread_id, ... }
  else
    local message = ...
    if type(message) == "table" and getmetatable(message) == runtime_assertion_metatable then
      self.send_channel:push { "success", message[1] }
    else
      self.send_channel:push { "failure", self.thread_id, ... }
    end
  end
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

function class:runtime_assert(a, b, ...)
  if a then
    return a, b, ...
  else
    if not b then
      b = "assertion failed"
    end
    error(setmetatable({ b }, runtime_assertion_metatable))
  end
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
