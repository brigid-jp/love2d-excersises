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

return function (promise, url, filename, size, sha256)
  local now = 0

  assert(socket.http.request {
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
  })

  if size then
    local fileinfo = assert(love.filesystem.getInfo(filename))
    assert(fileinfo.size == size)
  end

  if sha256 then
    assert(love.data.hash("sha256", assert(love.filesystem.newFileData(filename))) == sha256)
  end
end
