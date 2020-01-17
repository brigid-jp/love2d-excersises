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
  local intr_channel = love.thread.newChannel()

  local worker = {
    worker_id = worker_id;
    thread = thread;
    send_channel = send_channel;
    intr_channel = intr_channel;
    status = "idle";
  }
  self.workers[worker_id] = worker
  self.worker_count = self.worker_count + 1

  thread:start(worker_id, send_channel, self.recv_channel, intr_channel)

  return worker
end

local function new_task(self, ...)
  local task_id = self.task_id + 1
  self.task_id = task_id

  local task = {
    task_id = task_id;
    status = "pending";
    ...;
  }
  self.tasks[task_id] = task

  return task
end

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

  local worker_queue = queue()
  local self = {
    max_workers = max_workers;
    max_spare_workers = max_spare_workers;

    recv_channel = love.thread.newChannel();
    worker_id = 0;
    workers = {};
    worker_queue = worker_queue;
    worker_count = 0;

    task_id = 0;
    tasks = {};
    task_queue = queue();
  }

  for i = 1, start_workers do
    worker_queue:push(new_worker(self))
  end

  return self
end

local function run(self)
  local worker_queue = self.worker_queue
  local task_queue = self.task_queue

  while true do
    if task_queue:empty() then
      break
    end

    local worker = worker_queue:pop()
    if not worker then
      if self.worker_count < self.max_workers then
        worker = new_worker(self)
      else
        break
      end
    end
    worker.status = "active"
    local worker_id = worker.worker_id

    local task = task_queue:pop()
    task.status = "running"
    task.worker_id = worker_id

    worker.send_channel:push {
      task_id = task.task_id;
      "task", unpack(task);
    }
  end
end

local class = {}
local metatable = { __index = class }

function class:push(...)
  local task = new_task(self, ...)
  self.task_queue:push(task)
  run(self)
  return task
end

function class:cancel(task)
  if task.status == "running" then
    local worker_id = task.worker_id
    if worker_id then
      local worker = self.workers[worker_id]
      worker.intr_channel:push { "cancel" }
    end
  end
end

function class:update()
  local recv_channel = self.recv_channel
  local workers = self.workers
  local worker_queue = self.worker_queue
  local tasks = self.tasks
  local task_queue = self.task_queue

  while true do
    local msg = recv_channel:pop()
    if not msg then
      break
    end
    local name = msg[1]
    if name == "success" or name == "failure" then
      local worker = workers[msg.worker_id]
      worker.status = "idle"
      worker_queue:push(worker)

      local task = tasks[msg.task_id]
      task.status = status
      task.worker_id = nil
      task.result = { unpack(msg, 2) }
      print(("[%s] worker_id:%d task_id:%d"):format(status, msg.worker_id, msg.task_id))
    elseif name == "progress" then
      local task = tasks[msg.task_id]
      task.progress = { unpack(msg, 2) }
    elseif name == "quit" then
      local worker_id = msg.worker_id
      local worker = workers[worker_id]
      workers[woker_id] = nil
      self.worker_count = self.worker_count - 1
      worker.thread:wait()
      print(("[%s] worker_id:%d"):format(status, worker_id))
    end
  end

  if task_queue:empty() then
    while worker_queue:count() > self.max_spare_workers do
      local worker = worker_queue:pop()
      worker.send_channel:push { "quit" }
    end
  end
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
