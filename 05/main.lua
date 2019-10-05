local love = love
local g = love.graphics
local window = love.window

local font
local edited
local buffer = {}

function love.load()
  local width, height = window.getMode()

  font = g.newFont("mplus-1p-regular.ttf", 24)
  love.keyboard.setTextInput(true, 24, 24, width - 48, 24);
  -- love.keyboard.setTextInput(true);
end

function love.update(dt)
end

function love.draw()
  local width, height = window.getMode()

  if edited then
    g.setColor(1, 0, 0)
    g.printf(edited.text, font, 24, 24, width - 48)
  end

  g.setColor(1, 1, 0)
  g.printf(table.concat(buffer), font, 24, 48, width - 48)

  g.setColor(1, 1, 1)
  g.printf(("%s %s"):format(
      love.keyboard.hasTextInput(),
      love.keyboard.hasScreenKeyboard()), font, 24, 96, width - 48)
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
