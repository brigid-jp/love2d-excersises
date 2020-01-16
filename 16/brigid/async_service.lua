-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
  thread = require "love.thread";
}

local unpack = table.unpack or unpack

local queue = (function ()
  local class = {}
  local metatable = { __index = class }

  function class:empty()
    return self.m > self.n
  end

  function class:count()
    return self.n - self.m + 1
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
    status = "idle";
  }
  self.workers[worker_id] = worker
  self.worker_queue:push(worker)
  self.worker_count = self.worker_count + 1

  thread:start(worker_id, send_channel, self.recv_channel)

  return worker
end

local function new_task(self, ...)
  local task_id = self.task_id + 1
  self.task_id = task_id

  local task = {
    id = task_id;
    status = "pending";
    ...
  }
  self.tasks[task_id] = task
  self.task_queue:push(task)

  return task
end

local function run(self)
  local worker_queue = self.worker_queue
  local task_queue = self.task_queue

  while true do
    if task_queue:empty() then
      break
    end

    if worker_queue:empty() then
      if self.worker_count < self.max_workers then
        new_worker(self)
      else
        break
      end
    end
    local worker = worker_queue:pop()
    worker.status = "active"

    local task = task_queue:pop()
    task.status = "running"

    worker.send_channel:push { "task", task.id, unpack(task) }
  end
end

local class = {}
local metatable = { __index = class }

local function new(start_workers, max_workers, max_spare_workers)
  if not start_workers then
    start_workers = love.system.getProcessorCount()
  end
  if not max_workers then
    max_workers = start_workers
  end
  if not max_spare_workers then
    max_spare_workers = max_workers
  end

  local self = {
    max_workers = max_workers;
    max_spare_workers = max_spare_workers;

    recv_channel = love.thread.newChannel();
    worker_id = 0;
    workers = {};
    worker_queue = queue();
    worker_count = 0;

    task_id = 0;
    tasks = {};
    task_queue = queue();
  }

  for i = 1, start_workers do
    new_worker(self)
  end

  return self
end

function class:update()
  local recv_channel = self.recv_channel
  local workers = self.workers
  local worker_queue = self.worker_queue
  local task_queue = self.task_queue

  while true do
    local recv = recv_channel:pop()
    if not recv then
      break
    end
    local req = recv[1]
    local worker_id = recv[2]

    if req == "success" then
      local task_id = recv[3]
      print("success", "worker_id:" .. worker_id, "task_id:" .. task_id)
      local worker = workers[worker_id]
      worker.status = "idle"
      worker_queue:push(workers[worker_id])
      run(self)
    elseif req == "quit" then
      print("quit", "worker_id:" .. worker_id)
      local worker = workers[worker_id]
      workers[worker_id] = nil
      self.worker_count = self.worker_count - 1

      worker.thread:wait()
    end
  end

  if task_queue:empty() then
    while worker_queue:count() > self.max_spare_workers do
      local worker = worker_queue:pop()
      worker.send_channel:push { "quit" }
    end
  end
end

function class:push(...)
  local task = new_task(self, ...)
  print("push", "task_id:" .. task.id)
  run(self)
  return task
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
