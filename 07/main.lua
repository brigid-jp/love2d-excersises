local love = love
local g = love.graphics
local window = love.window

local events = {}

local function push_event(event)
  events[#events + 1] = event
end

local function encode_events(m)
  local n = #events
  local i = math.max(1, n - m + 1)
  return table.concat(events, "\n", i, n)
end

function love.load()
  local width, height, flags = window.getMode()
  flags.resizable = true;
  window.setMode(width, height, flags)
end

function love.resize()
end

function love.update(dt)
end

function love.draw()
  local width, height = window.getMode()
  g.printf(
      ("mode %.17g %.17g\n"):format(width, height) ..  encode_events(10),
      50, 50, width - 100)
end

function love.mousepressed(x, y, button, istouch, presses)
  if not istouch then
    push_event(("mousepressed %.17g %.17g %.17g %s"):format(x, y, button, istouch, presses))
  end
end

function love.mousereleased(x, y, button, istouch, presses)
  if not istouch then
    push_event(("mousereleased %.17g %.17g %.17g %s"):format(x, y, button, istouch, presses))
  end
end

function love.mousemoved(x, y, dx, dy, istouch)
  if not istouch then
    -- push_event(("mousemoved %.17g %.17g %.17g %.17g %s"):format(x, y, dx, dy, istouch))
  end
end

function love.wheelmoved(x, y)
  push_event(("wheelmoved %.17g %.17g"):format(x, y))
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  push_event(("touchpressed %s %.17g %.17g %.17g %.17g %.17g"):format(id, x, y, dx, dy, pressure))
end

function love.touchreleased(id, x, y, dx, dy, pressure)
  push_event(("touchreleased %s %.17g %.17g %.17g %.17g %.17g"):format(id, x, y, dx, dy, pressure))
end

function love.touchmoved(id, x, y, dx, dy, pressure)
  -- push_event(("touchmoved %s %.17g %.17g %.17g %.17g %.17g"):format(id, x, y, dx, dy, pressure))
end
