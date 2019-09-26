local love = love
local g = love.graphics
local window = love.window

function love.load()
  local width, height, flags = window.getMode()

  flags.resizable = true;

  window.setMode(width, height, flags)

  print("getDisplayOrientation", window.getDisplayOrientation)
end

function love.update(dt)
end

function love.draw()
  local width, height = window.getMode()

  local text = ([[
width: %d
height: %d
]]):format(width, height)

  g.printf(text, 50, 50, width - 100)
end
