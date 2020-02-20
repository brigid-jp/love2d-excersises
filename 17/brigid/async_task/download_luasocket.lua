-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
}
local socket = {
  http = require "socket.http";
}

local check_file = require "brigid.async_task.check_file"

return function (promise, url, filename, size, sha256)
  local now = 0

  local result, message = socket.http.request {
    url = url;
    sink = function (chunk, e)
      if chunk then
        if promise:check_canceled() then
          return nil, "canceled"
        end
        if now == 0 then
          love.filesystem.write(filename, chunk)
        else
          love.filesystem.append(filename, chunk)
        end
        now = now + #chunk
        promise:set_progress(now, size)
        return true
      elseif e then
        return nil, e
      end
    end;
  }
  if not result then
    return nil, message
  end

  return check_file(promise, filename, size, sha256)
end
