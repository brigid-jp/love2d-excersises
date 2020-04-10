local data = {}

function love.draw()
  local keys = {}
  for k in pairs(data) do
    keys[#keys + 1] = k
  end
  table.sort(keys)

  local text = {}
  for i = 1, #keys do
    local k = keys[i]
    text[i] = ("%s: %6.3f\n"):format(k, data[k])
  end

  local width = love.window.getMode()
  love.graphics.printf(table.concat(text), 50, 50, width - 100)
end

function love.gamepadaxis(j, axis, value)
  data["gamepad." .. axis] = value
end

function love.gamepadpressed(j, button)
  print("gamepadpressed", j:getGUID(), button)
end

function love.gamepadreleased(j, button)
  print("gamepadreleased", j:getGUID(), button)
end

function love.joystickadded(j)
  print("joystickadded", j:getGUID())
end

function love.joystickremoved(j)
  print("joystickremoved", j:getGUID())
end

function love.joystickaxis(j, axis, value)
  -- print("joystickaxis", j:getGUID(), axis, value)
end

