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
      filename = "brigid.so";
      size = 160744;
      sha256 = "\242\057\242\218\082\165\192\062\114\001\160\220\009\149\227\224\110\209\012\089\237\228\162\041\229\240\088\086\009\170\200\062";
    };
  };
  Windows = {
    x64 = {
      url = "http://brigid.jp/pub/brigid-1.4-win-x64.dll";
      filename = "brigid.dll";
      size = 109056;
      sha256 = "\159\033\224\253\071\249\141\083\235\018\139\219\050\160\173\053\103\023\021\031\227\085\043\216\016\198\024\223\132\029\152\114";
    };
    x86 = {
      url = "http://brigid.jp/pub/brigid-1.4-win-x86.so";
      filename = "brigid.dll";
      size = 86528;
      sha256 = "\177\115\029\241\154\050\204\143\169\120\144\053\086\183\063\105\008\014\106\046\109\049\045\188\055\237\104\048\095\007\161\071";
    };
  };
}

local function get_module_information()
  local system = module_informations[love.system.getOS()]
  if system then
    local arch = system[jit.arch]
    if arch then
      return arch, arch.filename
    end
  end
end

local function check(module_info, fileinfo)
  if module_info.size == fileinfo.size then
    return module_info.sha256 == love.data.hash("sha256", assert(love.filesystem.newFileData(module_info.filename)))
  end
end

local module_info, module_filename = get_module_information()

local result, message = pcall(function ()
  if module_info and module_filename then
    local fileinfo = love.filesystem.getInfo(module_filename)
    if fileinfo then
      if not check(module_info, fileinfo) then
        love.filesystem.remove(module_filename)
      end
    end
  end

  if pcall(function () require "brigid" end) then
    return
  end

  assert(module_info)

  local file = assert(love.filesystem.newFile(module_filename, "w"))
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

  assert(check(module_info, assert(love.filesystem.getInfo(module_filename))))
  require "brigid"
end)

local channel = love.thread.getChannel "brigid_bootloader"
if result then
  channel:push { result = "ok" }
else
  if module_filename then
    love.filesystem.remove(module_filename)
  end
  channel:push { result = "error", message = message }
end
