-- Copyright (c) 2019 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  filesystem = require "love.filesystem";
  thread = require "love.thread";
}
local http = require "socket.http"

local brigid_bootloader = require "brigid_bootloader"

local channel = love.thread.getChannel "brigid_bootloader"

local module = assert(brigid_bootloader.get_module_definition())
local file = assert(love.filesystem.newFile(module.filename, "w"))

http.request {
  url = module.url;
  sink = function (chunk, e)
    if chunk then
      file:write(chunk)
    elseif e then
      error(e)
    end
    return true
  end;
}

file:close()

if brigid_bootloader.check(module) then
  channel:push "ok"
else
  love.filesystem.remove(module.filename)
  channel:push "error"
end
