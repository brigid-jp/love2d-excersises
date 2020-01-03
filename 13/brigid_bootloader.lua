-- Copyright (c) 2019 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
  system = require "love.system";
  thread = require "love.thread";
}

local class = {}
local metatable = { __index = class }

class.module_definitions = {
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
  ["Windows/x86"] = {
    url = "http://brigid.jp/pub/brigid-1.4-win-x86.so";
    size = 86528;
    sha256 = "\177\115\029\241\154\050\204\143\169\120\144\053\086\183\063\105\008\014\106\046\109\049\045\188\055\237\104\048\095\007\161\071";
    filename = "brigid.dll";
  };
}

function class.check(module)
  local fileinfo = love.filesystem.getInfo(module.filename)
  if fileinfo then
    return fileinfo.size == module.size and love.data.hash("sha256", assert(love.filesystem.newFileData(module.filename))) == module.sha256
  end
end

function class.check_module(fileinfo, module_definition)
  if fileinfo.size == module_definition.size then
    local data = love.filesystem.newFileData(module_definition.filename)



  end

  return fileinfo.size == module.size and love.data.hash("sha256", assert(love.filesystem.newFileData(module.filename))) == module.sha256

end

function class.get_module_definition()
  local key = love.system.getOS() .. "/" .. jit.arch
  return class.module_definitions[love.system.getOS() .. "/" .. jit.arch]
end

local function new()
  local self = {}

  local remove = false
  local module_definition = class.get_module_definition()
  if module_definition then
    local filename = module_definition.filename
    local fileinfo = love.filesystem.getInfo(filename)
    if fileinfo then
      remove = true
      if fileinfo.size == module_definition.size then
        local data = love.filesystem.newFileData(filename)
        if data then
          if love.data.hash("sha256", data) == module_definition.sha256 then
            remove = false
          end
        end
      end
    end
  end
  if remove then
    love.filesystem.remove(filename)
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
    local message = channel:pop()
    if message then
      if message == "ok" then
        self.module = require "brigid"
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
