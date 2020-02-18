-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
  thread = require "love.thread";
  timer = require "love.timer";
}

local async_task = require "brigid.async_task"
local async_tasks = require "brigid.async_tasks"
local async_thread = require "brigid.async_thread"
local binary_heap = require "brigid.binary_heap"
local stack = require "brigid.stack"

local unpack = table.unpack or unpack

local function new_thread(self)
  local thread_id = self.thread_id + 1
  self.thread_id = thread_id

  local thread = async_thread(thread_id, self.recv_channel)
  self.thread_table[thread_id] = thread
  self.thread_count = self.thread_count + 1

  return thread
end

local function compare_pending_task(a, b)
  return a.task_id < b.task_id
end

local function get_pending_task_handle(task)
  return task.pending_task_handle
end

local function set_pending_task_handle(task, handle)
  task.pending_task_handle = handle
end

local function compare_waiting_task(a, b)
  return a.timeout < b.timeout
end

local function get_waiting_task_handle(task)
  return task_waiting_task_handle
end

local function set_waiting_task_handle(task, handle)
  task_waiting_task_handle = handle
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

  local thread_stack = stack()

  local self = {
    max_threads = max_threads;
    max_spare_threads = max_spare_threads;
    recv_channel = love.thread.newChannel();
    thread_id = 0;
    thread_table = {};
    thread_stack = thread_stack;
    thread_count = 0;
    task_id = 0;
    pending_tasks = binary_heap(compare_pending_task, get_pending_task_handle, set_pending_task_handle);
    waiting_tasks = binary_heap(compare_waiting_task, get_waiting_task_handle, set_waiting_task_handle);
  }

  for i = 1, start_threads do
    thread_stack:push(new_thread(self))
  end

  return self
end

local function run(self)
  local thread_stack = self.thread_stack
  local pending_tasks = self.pending_tasks

  while not pending_tasks:empty() do
    local thread = thread_stack:pop()
    if not thread then
      if self.thread_count < self.max_threads then
        thread = new_thread(self)
      else
        break
      end
    end
    thread:run(pending_tasks:pop())
  end
end

local function new_task(self, ...)
  local task_id = self.task_id + 1
  self.task_id = task_id

  local task = async_task(self, task_id, ...)
  self.pending_tasks:push(task)
  run(self)
  return task
end

local class = {}
local metatable = { __index = class }

function class:update()
  local recv_channel = self.recv_channel
  local thread_table = self.thread_table
  local thread_stack = self.thread_stack
  local waiting_tasks = self.waiting_tasks

  while true do
    local message = recv_channel:pop()
    if not message then
      break
    end

    local status = message[1]
    local thread_id = message[2]
    local thread = thread_table[thread_id]
    if status == "closed" then
      thread_table[thread_id] = nil
      self.thread_count = self.thread_count - 1
      thread:wait()
    elseif status == "progress" then
      thread:set_progress(unpack(message, 3))
    else
      thread_stack:push(thread)
      thread:set_ready(status, unpack(message, 3))
    end
  end

  if self.pending_tasks:empty() then
    for i = 1, thread_stack:count() - self.max_spare_threads do
      thread_stack:pop():close()
    end
  else
    run(self)
  end

  local current_time = love.timer.getTime()
  while not waiting_tasks:empty() do
    local task = waiting_tasks:peek()
    if task.timeout > current_time then
      break
    end
    waiting_tasks:pop()
    task:set_timeout()
  end
end

function class:shutdown()
  local thread_stack = self.thread_stack
  for i = 1, thread_stack:count() do
    thread_stack:pop():close()
  end
end

for i = 1, #async_tasks do
  local task = async_tasks[i]
  class[task] = function (self, ...)
    return new_task(self, task, ...)
  end
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
