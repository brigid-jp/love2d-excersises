local love = love
local g = love.graphics
local window = love.window

local image

function love.load()
  local width, height = window.getMode()
  window.setMode(width, height, {
    resizable = true;
  })
  image = g.newImage "l_hires.jpg"
end

function love.update()
end

function love.draw()
  g.draw(image, 0, 0, 0, 0.5)
end
