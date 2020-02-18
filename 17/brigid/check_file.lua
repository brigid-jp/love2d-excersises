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
    return false
  end

  if fileinfo.size ~= size then
    return false
  end

  if love.data.hash("sha256", assert(love.filesystem.newFileData(filename))) ~= sha256 then
    return false
  end

  return true
end
