-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
  thread = require "love.thread";
}

local async_task = require "brigid.async_task"
local async_thread = require "brigid.async_thread"
local queue = require "brigid.queue"

local unpack = table.unpack or unpack

local function new_thread(self)
  local thread_id = self.thread_id + 1
  self.thread_id = thread_id

  local thread = async_thread(thread_id, self.recv_channel)
  self.thread_table[thread_id] = thread
  self.thread_count = self.thread_count + 1

  return thread
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

  local thread_queue = queue()

  local self = {
    max_threads = max_threads;
    max_spare_threads = max_spare_threads;
    recv_channel = love.thread.newChannel();
    thread_id = 0;
    thread_table = {};
    thread_queue = thread_queue;
    thread_count = 0;
    task_queue = queue();
  }

  for i = 1, start_threads do
    thread_queue:push(new_thread(self))
  end

  return self
end

local function run(self)
  local thread_queue = self.thread_queue
  local task_queue = self.task_queue

  while not task_queue:empty() do
    local task = task_queue:peek()
    if task.status == "pending" then
      local thread = thread_queue:pop()
      if not thread then
        if self.thread_count < self.max_threads then
          thread = new_thread(self)
        else
          break
        end
      end
      task_queue:pop()
      thread:run(task)
    else
      task_queue:pop()
    end
  end
end

local function new_task(self, ...)
  local task = async_task(...)
  self.task_queue:push(task)
  run(self)
  return task
end

local class = {}
local metatable = { __index = class }

function class:update()
  local recv_channel = self.recv_channel
  local thread_table = self.thread_table
  local thread_queue = self.thread_queue

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
      thread:set_ready(status, unpack(message, 3))
      thread_queue:push(thread)
    end
  end

  if self.task_queue:empty() then
    local thread_queue = self.thread_queue
    for i = 1, thread_queue:count() - self.max_spare_threads do
      thread_queue:pop():close()
    end
  else
    run(self)
  end
end

function class:sleep(...)
  return new_task(self, "sleep", ...)
end

function class:sleep2(...)
  return new_task(self, "sleep2", ...)
end

function class:test1()
  local thread_queue = self.thread_queue
  while true do
    local thread = thread_queue:pop()
    if not thread then
      break
    end
    thread:close()
  end
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(new(...), metatable)
  end;
})
