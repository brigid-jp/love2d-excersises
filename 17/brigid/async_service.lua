-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
  thread = require "love.thread";
  timer = require "love.timer";
}

local queue = require "brigid.queue"
local async_task = require "brigid.async_task"
local async_thread = require "brigid.async_thread"

local function new_thread(self)
  local thread_id = self.thread_id + 1
  self.thread_id = thread_id

  local thread = async_thread(thread_id, self.recv_channel)
  self.thread_table[thread_id] = thread
  self.thread_queue:push(thread)
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

  local self = {
    max_threads = max_threads;
    max_spare_threads = max_spare_threads;
    recv_channel = love.thread.newChannel();
    thread_id = 0;
    thread_table = {};
    thread_queue = queue();
    thread_count = 0;
    task_queue = queue();
  }

  for i = 1, start_threads do
    new_thread(self)
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
      thread:run(task)
    end
    task_queue:pop()
  end
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

    local name = message[1]
    local thread_id = message[2]
    local thread = thread_table[thread_id]
    if name == "closed" then
      thread_table[thread_id] = nil
      self.thread_count = self.thread_count - 1
      thread:wait()
    elseif name == "progress" then
      thread:set_progress(unpack(message, 3))
    else
      thread:complete(name, unpack(message, 3))
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

function class:dispatch()
end

function class:sleep(...)
  local task = async_task("sleep", ...)
  self.task_queue:push(task)
  run(self)
  return task
end

function class:sleep2(...)
  local task = async_task("sleep2", ...)
  self.task_queue:push(task)
  run(self)
  return task
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
