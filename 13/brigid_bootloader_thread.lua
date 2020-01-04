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

local module_definition = brigid_bootloader.get_module_definition()
if not module_definition then
  channel:push "error"
  return
end

local filename = module_definition.filename
local file = love.filesystem.newFile(filename, "w")
if not file then
  channel:push "error"
  return
end

local result, code, header
pcall(function ()
  result, code, header = http.request {
    url = module_definition.url;
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
if result and code == 200 and fileinfo and brigid_bootloader.check(fileinfo, module_definition) then
  channel:push "ok"
else
  love.filesystem.remove(module_definition.filename)
  channel:push "error"
end
