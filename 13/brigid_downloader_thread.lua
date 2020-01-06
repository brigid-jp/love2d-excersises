-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  filesystem = require "love.filesystem";
  thread = require "love.thread";
}
local brigid = require "brigid"

local url, filename, size, sha256 = ...

local function check(fileinfo)
  if size then
    if size ~= fileinfo.size then
      return
    end
  end
  if sha256 then
    if sha256 ~= love.data.hash("sha256", assert(love.filesystem.newFileData(filename))) then
      return
    end
  end
  return true
end

local result, message = pcall(function ()
  if not filename then
    filename = assert(url:match "[^/]+$")
  end

  local fileinfo = love.filesystem.getInfo(filename)
  if fileinfo then
    if check(fileinfo) then
      return
    else
      love.filesystem.remove(filename)
    end
  end

  local writer = assert(brigid.file_writer(filename))
  local hasher = assert(brigid.hasher "sha256")

  local http_session = assert(brigid.http_session {
    write = function (data)
      writer:write(data)
      hasher:update(data)
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
  if sha256 then
    assert(sha256 == hasher:digest())
  end
end)

print(result, message)
