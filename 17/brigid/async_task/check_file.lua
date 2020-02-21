-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
}

return function (promise, filename, size, sha256)
  local fileinfo = promise:assert_failure(love.filesystem.getInfo(filename))
  if size then
    promise:assert_failure(size == fileinfo.size)
  end
  if sha256 then
    promise:assert_failure(sha256 == love.data.hash("sha256", assert(love.filesystem.newFileData(filename))))
  end
  return true
end
