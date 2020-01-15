-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  timer = require "love.timer";
  thread = require "love.thread";
}

local thread_id, recv_channel, send_channel = ...

while true do
  local recv = recv_channel:demand()
  if recv then
    print("recv", thread_id, recv)
    if recv == "stop" then
      break
    elseif recv[1] == "sleep" then
      print("sleeping", thread_id)
      love.timer.sleep(recv[2])
      print("slept", thread_id)
    end
    send_channel:push "ok"
  else
    print("timeout", thread_id)
  end
end
print("exit", thread_id)
