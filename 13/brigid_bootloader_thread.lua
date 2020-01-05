-- Copyright (c) 2019,2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
  system = require "love.system";
  thread = require "love.thread";
}
local http = require "socket.http"

local module_informations = {
  ["OS X"] = {
    x64 = {
      url = "http://brigid.jp/pub/brigid-1.4-osx-x64.so";
      size = 160744;
      sha256 = "\242\057\242\218\082\165\192\062\114\001\160\220\009\149\227\224\110\209\012\089\237\228\162\041\229\240\088\086\009\170\200\062";
      filename = "brigid.so";
    };
  };
  Windows = {
    x64 = {
      url = "http://brigid.jp/pub/brigid-1.4-win-x64.dll";
      size = 109056;
      sha256 = "\159\033\224\253\071\249\141\083\235\018\139\219\050\160\173\053\103\023\021\031\227\085\043\216\016\198\024\223\132\029\152\114";
      filename = "brigid.dll";
    };
    x86 = {
      url = "http://brigid.jp/pub/brigid-1.4-win-x86.so";
      size = 86528;
      sha256 = "\177\115\029\241\154\050\204\143\169\120\144\053\086\183\063\105\008\014\106\046\109\049\045\188\055\237\104\048\095\007\161\071";
      filename = "brigid.dll";
    };
  };
}

local function get_module_information()
  local system = module_informations[love.system.getOS()]
  if system then
    return system[jit.arch]
  end
end

local function check(module_info, fileinfo)
  if module_info.size == fileinfo.size then
    return module_info.sha256 == love.data.hash("sha256", assert(love.filesystem.newFileData(module_info.filename)))
  end
end

local channel = love.thread.getChannel "brigid_bootloader"
local module_info = get_module_information()
local filename

local result, message = pcall(function ()
  if module_info then
    filename = module_info.filename
    local fileinfo = love.filesystem.getInfo(filename)
    if fileinfo then
      if not check(module_info, fileinfo) then
        love.filesystem.remove(filename)
      end
    end
  end

  local module
  pcall(function () module = require "brigid" end)
  if module then
    return
  end

  assert(module_info)

  local file = assert(love.filesystem.newFile(filename, "w"))
  local result, message = pcall(function ()
    local _, code = http.request {
      url = module_info.url;
      sink = function (chunk, e)
        if chunk then
          file:write(chunk)
        elseif e then
          error(e)
        end
        return true
      end;
    }
    assert(code == 200)
  end)
  file:close()
  assert(result, message)

  assert(check(module_info, assert(love.filesystem.getInfo(filename))))
  require "brigid"
end)

if result then
  channel:push {
    result = "ok";
  }
else
  if filename then
    love.filesystem.remove(filename)
  end
  channel:push {
    result = "error";
    message = message;
  }
end

--[====[

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
]====]
