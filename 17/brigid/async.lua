-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  system = require "love.system";
  thread = require "love.thread";
  timer = require "love.timer";
}

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
      return setmetatable({ m = 1, n = 0 }, metatable)
    end;
  })
end)()

local async_task = (function ()
  local class = {}
  local metatable = { __index = class }

  function class:cancel()
    local status = self.status
    if status == "pending" then
      self.status = "canceled"
    elseif status == "running" then
      self.thread:cancel_task()
    end
  end

  return setmetatable(class, {
    __call = function (_, ...)
      return setmetatable({ status = "pending", ... }, metatable)
    end;
  })
end)()

local async_thread = (function ()
  local function new(thread_id, recv_channel)
    local thread = love.thread.newThread "brigid/async_thread.lua"
    local send_channel = love.thread.newChannel()
    local intr_channel = love.thread.newChannel()

    thread:start(thread_id, recv_channel, send_channel, intr_channel)

    return {
      thread_id = thread_id;
      thread = thread;
      send_channel = send_channel;
      intr_channel = intr_channel;
      status = "idle";
    }
  end

  local class = {}
  local metatable = { __index = class }

  function class:quit()
    return self.send_channel:push { "quit" }
  end

  function class:wait()
    self.thread:wait()
  end

  function class:run_task(task)
    self.status = "active"
    self.task = task
    task.status = "running"
    task.thread = self
    self.send_channel:push { "task", unpack(task) }
  end

  function class:cancel_task()
    self.intr_channel:push { "cancel" }
  end

  function class:complete_task(status, ...)
    local task = self.task
    self.status = "inactive"
    self.task = nil
    task.status = status
    task.thread = nil
    task.result = { ... }
    return task
  end

  return setmetatable(class, {
    __call = function (_, ...)
      return setmetatable(new(...), metatable)
    end;
  })
end)()

local async_service = (function ()
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

  local function process(self)
    local thread_queue = self.thread_queue
    local task_queue = self.task_queue

    while not task_queue:empty() do
      local task = task_queue:pop()
      if task.status == "pending" then
        local thread = thread_queue:pop()
        if not thread then
          if self.thread_count < self.max_threads then
            thread = new_thread(self)
          else
            break
          end
        end
        thread:run_task(task)
      end
    end
  end

  local class = {}
  local metatable = { __index = class }

  function class:update()
    local recv_channel = self.recv_channel
    local thread_table = self.thread_table

    while true do
      local message = recv_channel:pop()
      if not message then
        break
      end

      local name = message[1]
      local thread_id = message[2]
      local thread = thread_table[thread_id]
      print(name, thread_id)
      if name == "quit" then
        thread_table[thread_id] = nil
        self.thread_count = self.thread_count - 1
        thread:wait()
      elseif name == "progress" then
      else
        thread:complete_task(name, unpack(message, 3))
      end
    end
  end

  function class:dispatch()
  end

  function class:sleep(...)
    local task = async_task("sleep", ...)
    self.task_queue:push(task)
    process(self)
    return task
  end

  function class:test1()
    local thread_queue = self.thread_queue
    while true do
      local thread = thread_queue:pop()
      if not thread then
        break
      end
      thread:quit()
    end
  end

  return setmetatable(class, {
    __call = function (_, ...)
      return setmetatable(new(...), metatable)
    end;
  })
end)()

return {
  service = async_service;
}
