-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local class = {}
local metatable = { __index = class }

local id = 0

local function new(task)
  id = id + 1
  love.thread.newThread "brigid_downloader_thread.lua" :start(id, task)
  return {
    id = id;
  }
end

function class:status()
  local result = self.result
  if result then
    return result, self.message
  else
    return "running"
  end
end

function class:cancel()
  local channel = love.thread.getChannel("brigid_downloader" .. self.id .. "_cancel")
  channel:push { method = "cancel" }
end

function class:update()
  if not self.result then
    local channel = love.thread.getChannel("brigid_downloader" .. self.id .. "_result")
    local response = channel:pop()
    if response then
      self.result = response.result
      self.message = response.message
    end
  end
end

return setmetatable(class, {
  __call = function (_, task)
    return setmetatable(new(task), metatable)
  end;
})
