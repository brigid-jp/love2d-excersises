local love = {
  thread = require "love.thread";
}

local class = {}
local metatable = { __index = class }

function class.new()
  local self = {}
  pcall(function () self.module = require "brigid" end)
  if self.module then
    self.state = "loaded"
  else
    self.state = "loading"
    local thread = love.thread.newThread "brigid_loader_thread.lua"
    thread:start()
  end
  return self
end

function class:update()
  if self.state == "loading" then
    local channel = love.thread.getChannel "brigid_loader"
    local message = channel:pop()
    if message then
      if message == "ok" then
        pcall(function () self.module = require "brigid" end)
      end
      if self.module then
        self.state = "loaded"
      else
        self.state = "error"
      end
    end
  end
  return self.state
end

return setmetatable(class, {
  __call = function ()
    return setmetatable(class.new(), metatable)
  end;
})
