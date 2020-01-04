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

local module = brigid_bootloader.get_module()
if not module then
  return channel:push {
    result = "error";
    message = "no module";
  }
end

local filename = module.filename
local file, message = love.filesystem.newFile(filename, "w")
if not file then
  return channel:push {
    result = "error";
    message = "cannot newFile: " .. message;
  }
end

local result, code, header
pcall(function ()
  result, code, header = http.request {
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
end)
file:close()

local fileinfo = love.filesystem.getInfo(filename)
if result and code == 200 and fileinfo and brigid_bootloader.check(fileinfo, module) then
  channel:push "ok"
else
  love.filesystem.remove(module.filename)
  channel:push "error"
end
