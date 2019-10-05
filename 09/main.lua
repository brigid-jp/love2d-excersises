local love = love
local g = love.graphics
local window = love.window

local thread
local buffer = { "false\n" }

function love.load()
  thread = love.thread.newThread "thread.lua"
  thread:start()
  buffer[1] = tostring(thread:isRunning()) .. "\n"
end

function love.update(dt)
  buffer[1] = tostring(thread:isRunning()) .. "\n"
  local ch = love.thread.getChannel "status"
  while true do
    local v = ch:pop()
    if not v then
      break
    end
    buffer[#buffer + 1] = v[1] .. " " .. v[2] .. "\n"
  end
end

function love.draw()
  local width, height = window.getMode()
  g.printf(table.concat(buffer), 0, 50, width)
end
