-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
}
local s = ...

local t = love.timer.getTime()
print(("love.load %.17g"):format(t - s))

-- local thread_id = ...
-- 
-- for i = 1, 40 do
--   love.timer.sleep(0.05)
--   -- print(thread_id, i)
-- end
