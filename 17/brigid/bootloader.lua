-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
}

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
      return arch
    end
  end
end

return function (service)
  local module_information = get_module_information()
  if not module_information then
    return
  end

  local filename = module_information.filename
  local size = module_information.size
  local sha256 = module_information.sha256

  local f = service:check_file(filename, size, sha256)
  if f:get() then
    return
  end

  local f = service:luasocket_download(module_information.url, filename, size, sha256)
  if f:get() then
    return
  end
end
