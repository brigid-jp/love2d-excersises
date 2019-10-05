require "love.timer"

local urls = {
  "test1.txt";
  "test2.txt";
  "test3.txt";
}

local ch = love.thread.getChannel "status"

for i = 1, #urls do
  local url = urls[i]
  ch:push { "start", url }
  love.timer.sleep(0.5)
  ch:push { "done", url }
end
