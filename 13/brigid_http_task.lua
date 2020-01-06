-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local unpack = table.unpack or unpack
local love = {
  thread = require "love.thread";
}

local class = {}
local metatable = { __index = class }

local id = 0

local function new(request)
  id = id + 1
  love.thread.newThread "brigid_http_thread.lua" :start(id, request)
  return { id = id }
end

function class:cancel()
  local channel = love.thread.getChannel("brigid_http" .. self.id .. "_interrupt")
  channel:push { "cancel" }
end

function class:update()
  if not self.result then
    local channel = love.thread.getChannel("brigid_http" .. self.id)
    while true do
      local message = channel:pop()
      if not message then
        break
      end
      if message[1] == "progress" then
        self.progress = message
      else
        self.result = message
        break
      end
    end
  end
end

function class:running()
  return not self.result
end

function class:get_progress()
  local progress = self.progress
  if progress then
    return unpack(progress, 2)
  end
end

function class:get_result()
  local result = self.result
  if result then
    return unpack(result)
  end
end

return setmetatable(class, {
  __call = function (_, request)
    return setmetatable(new(request), metatable)
  end;
})
