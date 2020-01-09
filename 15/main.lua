local unpack = table.unpack or unpack

local g = love.graphics

local font
local thread

function love.load()
  thread = love.thread.newThread "thread.lua"
  thread:start(love.timer.getTime())
end

function love.update(dt)
  if not thread:isRunning() then
    local channel = love.thread.getChannel "brigid_fontloader"
    while true do
      local result = channel:pop()
      if not result then
        break
      end
      local result, message = unpack(result)
      if result then
        local s = love.timer.getTime()
        font = g.newFont(message)
        local t = love.timer.getTime()
        print("newFont", t - s)
      end
    end
  end
end

function love.draw()
  local x, y, w, h = love.window.getSafeArea()
  if font then
    g.printf("フォントがロードされました", font, x + 24, y + 24, w - 48)
  else
    g.printf("loading font...", x + 24, y + 24, w - 48)
  end
end
