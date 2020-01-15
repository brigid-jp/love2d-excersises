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
  self.worker_id = worker_id

  local thread = love.thread.newThread "brigid/async_worker.lua"
  local send_channel = love.thread.newChannel()
  local worker = {
    thread = thread;
    send_channel = send_channel;
  }

  self.idle_workers[worker_id] = worker
  self.spare_threads = self.spare_threads + 1
  self.current_threads = self.current_threads + 1

  thread:start(worker_id, send_channel, self.recv_channel)

  return worker_id, worker
end

local function push_task(self, task)
  local tasks = self.tasks
  local m = tasks.m
  local n = tasks.n + 1
  tasks[n] = task
  tasks.n = n
end

local function peek_task(self)
  local tasks = self.tasks
  local m = tasks.m
  local n = tasks.n
  if m <= n then
    return tasks[m]
  end
end

local function pop_task(self)
  local tasks = self.tasks
  local m = tasks.m
  local n = tasks.n
  if m <= n then
    local task = tasks[m]
    tasks[m] = nil
    tasks.m = m + 1
    return task
  end
end

local function send_tasks(self)
  local idle_workers = self.idle_workers

  while true do
    local task = peek_task(self)
    if not task then
      break
    end

    local worker_id, worker = next(idle_workers)
    if not worker_id then
      break
    end

    idle_workers[worker_id] = nil
    self.active_workers[worker_id] = worker
    self.spare_threads = self.spare_threads - 1
    worker.send_channel:push(pop_task(self))
  end
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
    task_id = 0;
    recv_channel = love.thread.newChannel();
    idle_workers = {};
    active_workers = {};
    tasks = { m = 1; n = 0 };
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
      send_tasks(self)
    end

    -- task/progress
    -- task/success
    -- task/failure
    -- thread/bye
  end
end

function class:push(...)
  local task_id = self.task_id + 1
  self.task_id = task_id

  push_task(self, { id = task_id; ... })
  send_tasks(self)
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
