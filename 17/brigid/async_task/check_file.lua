-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
}

return function (promise, filename, size, sha256)
  local fileinfo = love.filesystem.getInfo(filename)
  if not fileinfo then
    return nil, "no such file"
  end

  if size then
    if size ~= fileinfo.size then
      return nil, "invalid file size"
    end
  end

  if sha256 then
    if sha256 ~= love.data.hash("sha256", assert(love.filesystem.newFileData(filename))) then
      return nil, "checksum mismatch"
    end
  end

  return true
end
