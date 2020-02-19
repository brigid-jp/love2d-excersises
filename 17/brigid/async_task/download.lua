-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
}

print("brigid loading")
local brigid = require "brigid"
print("brigid loaded")

return function (promise, url, filename, size, sha256)
  local path = love.filesystem.getSaveDirectory() .. "/" .. filename
  local writer = assert(brigid.file_writer(path))
  local hasher = assert(brigid.hasher "sha256")
  local now = 0

  local http_session = assert(brigid.http_session {
    write = function (data)
      if promise:check_canceled() then
        return false
      end
      assert(writer:write(data))
      assert(hasher:update(data))
      now = now + data:get_size()
      promise:set_progress(now, size)
    end;
  })

  assert(http_session:request {
    method = "GET";
    url = url;
    header = {
      ["User-Agent"] = "brigid/" .. brigid.get_version();
    };
  })

  writer:close()

  if size then
    assert(size == now)
  end

  if sha256 then
    assert(sha256 == hasher:digest())
  end
end
