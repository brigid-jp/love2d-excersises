-- Copyright (c) 2019,2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
  system = require "love.system";
  thread = require "love.thread";
}

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

local class = {}
local metatable = { __index = class }

function class.get_module()
  local module = module_informations[love.system.getOS()]
  if module then
    return module[jit.arch]
  end
end

function class.check(fileinfo, module)
  if fileinfo.size == module.size then
    local data = love.filesystem.newFileData(module.filename)
    if data then
      return love.data.hash("sha256", data) == module.sha256
    end
  end
end

local function new()
  local self = {}

  local module = class.get_module()
  if module then
    local filename = module.filename
    local fileinfo = love.filesystem.getInfo(filename)
    if fileinfo then
      if not class.check(fileinfo, module) then
        love.filesystem.remove(filename)
      end
    end
  end

  pcall(function () self.module = require "brigid" end)

  if self.module then
    self.state = "loaded"
  else
    self.state = "loading"
    love.thread.newThread "brigid_bootloader_thread.lua" :start()
  end

  return self
end

function class:update()
  if self.state == "loading" then
    local channel = love.thread.getChannel "brigid_bootloader"
    while true do
      local message = channel:pop()
      if not message then
        break
      end
      print(message)
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
    return setmetatable(new(), metatable)
  end;
})
