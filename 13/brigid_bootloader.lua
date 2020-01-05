-- Copyright (c) 2019,2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  thread = require "love.thread";
}

local class = {}
local metatable = { __index = class }

local function new()
  love.thread.newThread "brigid_bootloader_thread.lua" :start()
  return { state = "loading" }
end

function class:update()
  if self.state == "loading" then
    local channel = love.thread.getChannel "brigid_bootloader"
    while true do
      local response = channel:pop()
      if not response then
        break
      end
      local result = response.result
      if result == "ok" then
        self.state = "loaded"
        self.module = require "brigid"
      elseif result == "error" then
        self.state = "error"
        self.message = response.message
      end
    end
  end
  return self.state
end

return setmetatable(class, {
  __call = function ()
    return setmetatable(new(), metatable)
  end;
})
