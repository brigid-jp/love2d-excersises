-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
}

local async_service = require "brigid.async_service"

local module_informations = {
  ["OS X"] = {
    x64 = {
      url = "http://brigid.jp/pub/brigid-1.5-osx-x64.so";
      filename = "brigid.so";
      size = 155144;
      sha256 = "\254\203\187\192\165\020\082\180\239\165\179\145\085\065\033\132\201\014\108\146\215\069\064\026\046\102\159\210\021\106\065\212";
    };
  };
  Windows = {
    x64 = {
      url = "http://brigid.jp/pub/brigid-1.5-win-x64.dll";
      filename = "brigid.dll";
      size = 103936;
      sha256 = "\143\033\140\230\053\206\239\088\056\200\179\217\233\105\241\172\035\184\172\020\183\131\065\147\219\067\107\088\168\142\246\245";
    };
    x86 = {
      url = "http://brigid.jp/pub/brigid-1.5-win-x86.dll";
      filename = "brigid.dll";
      size = 82432;
      sha256 = "\189\032\147\219\246\006\150\196\200\185\117\241\098\112\208\059\189\051\236\125\127\171\053\079\167\048\236\018\136\007\093\090";
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
    return false
  end

  local filename = module_information.filename
  local size = module_information.size
  local sha256 = module_information.sha256

  local f = service:check_file(filename, size, sha256)
  if f:get() then
    return false
  end

  local f = service:download_luasocket(module_information.url, filename, size, sha256)
  f:get()
  return true
end
