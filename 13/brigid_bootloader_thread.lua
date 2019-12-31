-- Copyright (c) 2019 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
  system = require "love.system";
  thread = require "love.thread";
}
local http = require "socket.http"

local modules = {
  ["OS X/x64"] = {
    url = "http://brigid.jp/pub/brigid-1.4-osx-x64.so";
    size = 160744;
    sha256 = "\242\057\242\218\082\165\192\062\114\001\160\220\009\149\227\224\110\209\012\089\237\228\162\041\229\240\088\086\009\170\200\062";
    filename = "brigid.so";
  };
  ["Windows/x64"] = {
    url = "http://brigid.jp/pub/brigid-1.4-win-x64.dll";
    size = 109056;
    sha256 = "\159\033\224\253\071\249\141\083\235\018\139\219\050\160\173\053\103\023\021\031\227\085\043\216\016\198\024\223\132\029\152\114";
    filename = "brigid.dll";
  };
}

local function check(module)
  local fileinfo = love.filesystem.getInfo(module.filename)
  if fileinfo then
    return fileinfo.size == module.size and love.data.hash("sha256", assert(love.filesystem.newFileData(module.filename))) == module.sha256
  end
end

local channel = love.thread.getChannel "brigid_bootloader"

local module = assert(modules[love.system.getOS() .. "/" .. jit.arch])
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

if check(module) then
  channel:push "ok"
else
  love.filesystem.remove(module.filename)
  channel:push "error"
end
