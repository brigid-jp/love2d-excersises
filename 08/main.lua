local love = love
local g = love.graphics
local window = love.window

local joysticks = {}

function love.draw()
end

function love.joystickadded(j)
  print("joystickadded", j:getGUID())
end

function love.joystickremoved(j)
  -- print("joystickremoved", j:getDeviceInfo())
end
