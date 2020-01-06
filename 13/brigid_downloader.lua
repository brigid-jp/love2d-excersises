-- Copyright (c) 2019,2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local class = {}
local metatable = { __index = class }

local id = 0

local function new()
  id = id + 1
  local channel_name = "brigid_downloader" .. id
  local thread = love.thread.newThread "brigid_downloader_thread.lua"
  thread:start(info, channel_name)

  return { state = "processing" }
end

function class:update()
end

function class:cancel()
end

return setmetatable(class, {
  __call = function ()
    return setmetatable(new(), metatable)
  end;
})
