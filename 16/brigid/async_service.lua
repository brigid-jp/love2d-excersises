-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
  thread = require "love.thread";
}

local unpack = table.unpack or unpack

local queue_t = (function ()
  local class = {}
  local metatable = { __index = class }

  function class:empty()
    return self.m > self.n
  end

  function class:push(item)
    local m = self.m
    local n = self.n + 1
    self.n = n
    self[n] = item
    return self
  end

  function class:pop()
    local m = self.m
    local n = self.n
    if m > n then
      return
    end
    local item = self[m]
    self.m = m + 1
    self[m] = nil
    return item
  end

  return setmetatable(class, {
    __call = function ()
      return setmetatable({ m = 1; n = 0 }, metatable)
    end;
  })
end)()

local function new_worker(self)
  local worker_id = self.worker_id + 1
  self.worker_id = worker_id

  local thread = love.thread.newThread "brigid/async_worker.lua"
  local send_channel = love.thread.newChannel()

  local worker = {
    id = worker_id;
    thread = thread;
    send_channel = send_channel;
  }
  self.workers[worker_id] = worker
  self.worker_queue:push(worker)

  thread:start(worker_id, send_channel, self.recv_channel)

  return worker_id, worker
end

local class = {}
local metatable = { __index = class }

local function send_tasks(self)
  local worker_queue = self.worker_queue
  local task_queue = self.task_queue

  while true do
    if task_queue:empty() then
      break
    end

    if worker_queue:empty() then
      break
    end

    local worker = worker_queue:pop()

    local task = task_queue:pop()

    task.status = "running"

    worker.send_channel:push { "task", task.id, unpack(task) }
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
    recv_channel = love.thread.newChannel();
    worker_id = 0;
    workers = {};
    worker_queue = queue_t();

    task_id = 0;
    tasks = {};
    task_queue = queue_t();

    max_threads = max_threads;
    max_spare_threads = max_spare_threads;
    -- spare_threads = 0;
    -- current_threads = 0;
  }

  for i = 1, start_threads do
    new_worker(self)
  end

  return self
end

function class:update()
  local recv_channel = self.recv_channel
  local workers = self.workers
  local worker_queue = self.worker_queue

  while true do
    local recv = recv_channel:pop()
    if not recv then
      break
    end
    local req = recv[1]
    if req == "success" then
      -- save result
      local worker_id = recv[2]
      local task_id = recv[3]
      print("success", worker_id, task_id)
      -- self.idle_workers[worker_id] = self.active_workers[worker_id]
      -- self.active_workers[worker_id] = nil
      -- self.spare_threads = self.spare_threads + 1
      worker_queue:push(workers[worker_id])
      send_tasks(self)
    end

    -- task/progress
    -- task/success
    -- task/failure
    -- thread/bye
  end
end

function class:push(...)
  -- generate task id
  local task_id = self.task_id + 1
  self.task_id = task_id

  -- create task
  local task = {
    id = task_id;
    status = "pending";
    ...
  }
  self.tasks[task_id] = task
  self.task_queue:push(task)

  -- send tasks
  send_tasks(self)
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
