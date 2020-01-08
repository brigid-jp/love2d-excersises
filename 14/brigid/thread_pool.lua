-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local class = {}
local metatable = { __index = class }

local function construct(max_threads, max_spare_threads)
  local threads = {}
  for i = 1, #max_threads do
    local thread = love.thread.newThread()
  end
  return {}
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(construct(...), metatable)
  end;
})
