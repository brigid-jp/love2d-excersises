local love = love
local g = love.graphics
local window = love.window

local font
local edited
local buffer = {}

function love.load()
  local width, height = window.getMode()

  print("load", width, height)

  font = g.newFont("mplus-1p-regular.ttf", 24)
  -- love.keyboard.setTextInput(true, 24, 24, width - 48, 24);
  -- love.keyboard.setTextInput(true);
end

function love.update(dt)
  love.timer.sleep(0.02)
end

function love.resize(w, h)
  print("resize", w, h)
  -- love.keyboard.setTextInput(true, 0, h - 24, w, 24);
end

function love.draw()
  local width, height = window.getMode()

  -- if not love.keyboard.hasTextInput() then
  --   -- love.keyboard.setTextInput(true)
  --   love.keyboard.setTextInput(true, 0, height - 24, width, 24);
  --   -- love.keyboard.setTextInput(true, 0, 0, width, 24);
  -- end

  -- print("draw", width, height)

  if edited then
    g.setColor(1, 0, 0)
    g.printf(edited.text, font, 24, height - 96, width - 48)
  end

  g.setColor(1, 1, 0)
  g.printf(table.concat(buffer), font, 24, height - 72, width - 48)

  g.setColor(1, 1, 1)
  g.printf(("%s %s"):format(
      love.keyboard.hasTextInput(),
      love.keyboard.hasScreenKeyboard()), font, 24, height - 48, width - 48)

  love.timer.sleep(0.015)
end

function love.keypressed(key)
  print("keypressed", key)
  if key == "return" then
    if not edited then
      buffer[#buffer + 1] = "\n"
    end
  end
end

function love.keyreleased(key)
  print("keyreleased", key)
end

function love.textedited(text, start, length)
  print("textedited", text, start, length)
  if edited then
    edited.text = text
    edited.start = start
    edited.length = length
  else
    edited = {
      text = text;
      start = start;
      length = length;
    }
  end
end

function love.textinput(text)
  print("textinput", text)
  edited = nil
  buffer[#buffer + 1] = text
end

function love.mousepressed(x, y, button, istouch, presses)
  if love.keyboard.hasTextInput() then
    love.keyboard.setTextInput(false)
  else
    local width, height = window.getMode()
    love.keyboard.setTextInput(true, 0, height - 24, width, 24);
  end
end
