-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local binary_heap = require "brigid.binary_heap"

local super = binary_heap
local class = {}
local metatable = { __index = class }

function class.new(comp, name)
  local self = super.new(comp)
  self.name = name
  return self
end

function class:push(item)
  local handle = super.push(self, item)
  item[self.name] = handle
end

function class:pop()
  local item = super.pop(self)
  if item then
    item[self.name] = nil
  end
  return item
end

function class:remove(item)
  local name = self.name
  local handle = item[name]
  if handle then
    item[name] = nil
    super.remove(self, handle)
  end
end

return setmetatable(class, {
  __index = super;
  __call = function (_, ...)
    return setmetatable(class.new(...), metatable)
  end;
})
