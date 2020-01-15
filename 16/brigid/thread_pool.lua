-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
  thread = require "love.thread";
}

local class = {}
local metatable = { __index = class }

local function new_idle_thread(self)
  local thread_id = self.thread_id + 1
  local thread = love.thread.newThread "brigid/thread.lua"
  local send_channel = love.thread.newChannel()

  print("new_idle_thread", thread_id)

  local thread_info = {
    thread = thread;
    send_channel = send_channel;
  }

  self.thread_id = thread_id
  self.idle_threads[thread_id] = thread_info
  self.spare_threads = self.spare_threads + 1
  self.current_threads = self.current_threads + 1

  thread:start(thread_id, send_channel, self.recv_channel)
  return thread_id, thread_info
end

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

  local self = {
    thread_id = 0;
    threads = {};
    idle_threads = {};
    recv_channel = love.thread.newChannel();
    max_threads = max_threads;
    max_spare_threads = max_spare_threads;
    spare_threads = 0;
    current_threads = 0;
  }

  for i = 1, start_threads do
    new_idle_thread(self)
  end

  return self
end

function class:update()
  local recv_channel = self.recv_channel
  while true do
    local recv = recv_channel:pop()
    if not recv then
      break
    end
    local req = recv[1]
    if req == "success" then
      -- save result
      local thread_id = recv[2]
      print("success", thread_id)
      self.idle_threads[thread_id] = self.threads[thread_id]
      self.threads[thread_id] = nil
      self.spare_threads = self.spare_threads + 1
    end

    -- task/progress
    -- task/success
    -- task/failure
    -- thread/bye
  end
end

function class:push(task)
  local idle_threads = self.idle_threads

  local thread_id, thread_info = next(idle_threads)
  if not thread_id then
    thread_id, thread_info = new_idle_thread(self)
  end
  idle_threads[thread_id] = nil
  self.threads[thread_id] = thread_info
  self.spare_threads = self.spare_threads - 1

  thread_info.send_channel:push(task)
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
