-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
}

local brigid = require "brigid"
local check_file = require "brigid.async_task.check_file"

return function (promise, url, filename, size, sha256)
  local path = love.filesystem.getSaveDirectory() .. "/" .. filename
  local now = 0

  local writer, message = brigid.file_writer(path)
  if not writer then
    return nil, message
  end

  local http_session = assert(brigid.http_session {
    write = function (data)
      if promise:check_canceled() then
        return false
      end
      assert(writer:write(data))
      now = now + data:get_size()
      promise:set_progress(now, size)
    end;
  })

  local result, message = http_session:request {
    method = "GET";
    url = url;
    header = {
      ["User-Agent"] = "brigid/" .. brigid.get_version();
    };
  }

  writer:close()

  if not result then
    love.filesystem.remove(filename)
    return nil, message
  end

  return check_file(promise, filename, size, sha256)
end
