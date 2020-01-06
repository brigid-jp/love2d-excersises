-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  thread = require "love.thread";
}

--[[

progress(dnow, dtotal)

Lua

coroutine
status => running or dead
coroutine.resume => pcall syntax
coroutine.close => cancel (toclose)

C++

future, promise
status => deferred or ready
get() => throw exception

progress = {
  upload = {
    now = ?,
    total = ?,
  };
}

progress_upload_now
progress_upload_total
progress_download_now
progress_download_total

]]

local class = {}
local metatable = { __index = class }

local id = 0

local function new(request)
  id = id + 1
  love.thread.newThread "brigid_download_thread.lua" :start(id, request)
  return { id = id }
end

function class:cancel()
  local channel = love.thread.getChannel("brigid_download" .. self.id .. "_progress")
  channel:push { "cancel" }
end

function class:update()
  if not self.ready then
    local channel = love.thread.getChannel("brigid_download" .. self.id)
    while true do
      local message = channel:pop()
      if not message then
        break
      end
      local status = message[1]
      if status == "upload" then
        self.upload_now = message[2]
        self.upload_total = message[3]
      end


      local status = message.status
      if status == "uploading" then
        self.progress_now = message.now
        self.progress_total = message.total
      elseif status == "downloading" then
      elseif status == "ok" then
        self.result = "ok"
        self.ready = true
        break
      elseif status == "error" then
        self.result = "error"
        self.ready = true
        self.error_message = message.message
        break
      end
    end
  end
end

function class:get_status()
  -- uploading
  -- downloading
  -- ok
  -- error, message

end

function class:get_result()
end

