local t = 0

function love.load()

  local thread = love.thread.newThread "brigid/thread.lua"
  local s = love.timer.getTime()
  thread:start(s)

  --[[
  --  25us newThread
  -- 100us newThread, start

  local threads = {}
  for i = 1, 1000 do
    local thread = love.thread.newThread "brigid/thread.lua"
    thread:start(i)
    threads[i] = thread
  end

  local t = love.timer.getTime()

  print(("love.load %.17g"):format(t - s))
  ]]


end

function love.update(dt)
  t = t + dt
  if t > 2 then
    love.event.quit()
  end
end

function love.quit()
  print "love.quit"
  return false
end

function love.draw()
  -- print "love.draw"
end
