-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
  thread = require "love.thread";
}

local class = {}
local metatable = { __index = class }

local function new_worker(self)
  local worker_id = self.worker_id + 1

  local thread = love.thread.newThread "brigid/async_worker.lua"
  local send_channel = love.thread.newChannel()

  local worker = {
    thread = thread;
    send_channel = send_channel;
  }

  self.worker_id = worker_id
  self.idle_workers[worker_id] = worker
  self.spare_threads = self.spare_threads + 1
  self.current_threads = self.current_threads + 1

  thread:start(worker_id, send_channel, self.recv_channel)
  return worker_id, worker
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
    worker_id = 0;
    active_workers = {};
    idle_workers = {};
    recv_channel = love.thread.newChannel();
    max_threads = max_threads;
    max_spare_threads = max_spare_threads;
    spare_threads = 0;
    current_threads = 0;
  }

  for i = 1, start_threads do
    new_worker(self)
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
      local worker_id = recv[2]
      print("success", worker_id)
      self.idle_workers[worker_id] = self.active_workers[worker_id]
      self.active_workers[worker_id] = nil
      self.spare_threads = self.spare_threads + 1
    end

    -- task/progress
    -- task/success
    -- task/failure
    -- thread/bye
  end
end

function class:push(task)
  local idle_workers = self.idle_workers

  local worker_id, worker = next(idle_workers)
  if not worker_id then
    worker_id, worker = new_worker(self)
  end
  idle_workers[worker_id] = nil
  self.active_workers[worker_id] = worker
  self.spare_threads = self.spare_threads - 1

  worker.send_channel:push(task)
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
