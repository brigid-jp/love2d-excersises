-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
  thread = require "love.thread";
}

local class = {}
local metatable = { __index = class }

local function new(start_threads, max_threads, max_spare_threads)
  if not start_threads then
    start_threads = love.system.getProcessorCount()
  end
  if not max_threads then
    max_threads = start_threads
  end
  if not max_spare_threads then
    max_spare_threads = max_threads
  end

  local threads = {}
  for i = 1, start_threads do
    local thread = love.thread.newThread "brigid/thread.lua"
    local send_channel = love.thread.newChannel()
    local recv_channel = love.thread.newChannel()
    thread:start(i, send_channel, recv_channel)
    threads[i] = {
      thread = thread;
      send_channel = send_channel;
      recv_channel = recv_channel;
    }
  end

  -- spare_threads / idle_threads
  -- current_threads -- all

  return {
    threads = threads;
    -- max_threads = max_threads;
    -- max_spare_threads = max_spare_threads;
    -- spare_threads = #threads;
    -- current_threads = #threads;
    -- crreunt_tasks = 0;
  }
end

function class:stop_all()
  for k, v in pairs(self.threads) do
    v.send_channel:push "stop"
  end
end

function class:sleep(thread_id, s)
  self.threads[thread_id].send_channel:push {"sleep", s }
end

function class:wait_all()
  for k, v in pairs(self.threads) do
    v.thread:wait()
  end
  print "wait_all"
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
