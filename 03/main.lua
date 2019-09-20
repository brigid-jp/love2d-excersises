local character = require "character"
local isDown = love.keyboard.isDown

local love = love
local g = love.graphics
local keyboard = love.keyboard
local window = love.window

local characters = {}
local character_i = 1

function love.load()
  local character_filenames = {
    "1011010501.png";
    "1012010501.png";
    "1087010501.png";
    "1104010501.png";
    "1114010501.png";
    "1173010501.png";
    "1248010501.png";
    "1340010501.png";
    "1341010501.png";
    "1345010501.png";
  }

  for i = 1, #character_filenames do
    characters[i] = character(character_filenames[i], (i - 1) * 48)
  end
end

function love.update(dt)
  for i = 1, #characters do
    characters[i]:update(dt, i == character_i)
  end
end

function love.draw()
  for i = 1, #characters do
    characters[i]:draw()
  end
end

function love.keypressed(key, scancode, isrepeat)
  print("keypressed", key, scancode, isrepeat)
  if key == "space" then
    local i = character_i
    local n = #characters
    if isDown "lshift" or isDown "rshift" then
      i = i - 1
      if i < 1 then
        i = n
      end
    else
      i = i + 1
      if i > n then
        i = 1
      end
    end
    character_i = i
  end
end
