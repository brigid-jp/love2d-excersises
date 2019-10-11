local love = love
local g = love.graphics
local window = love.window

local thread
local buffer = { "false\n" }
local font

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
    buffer[#buffer + 1] = table.concat(v, " ") .. "\n"
    if v[1] == "fetched" and v[2]:find "%.[ot]tf" then
      font = g.newFont(v[2], 24)
    end
  end
end

function love.draw()
  local width, height = window.getMode()
  if font then
    g.printf(table.concat(buffer), font, 0, 50, width)
  else
    g.printf(table.concat(buffer), 0, 50, width)
  end
end
