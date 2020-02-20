-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
}

return function (promise, t, n)
  if not n then
    n = 1
  end

  local s = t / n
  promise:set_progress(0, n)
  for i = 1, n do
    if promise:check_canceled() then
      error "canceled"
    end
    love.timer.sleep(s)
    promise:set_progress(i, n)
  end

  return true
end
