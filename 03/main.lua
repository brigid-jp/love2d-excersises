local character = require "character"

local love = love
local g = love.graphics
local keyboard = love.keyboard
local window = love.window

local characters = {}
local character_i = 9

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
    characters[i] = character(character_filenames[i])
  end
end

function love.update(dt)
  local character = characters[character_i]
  character:update(dt)
end

function love.draw()
  local character = characters[character_i]
  character:draw()
end

function love.keypressed(key, scancode, isrepeat)
  print("keypressed", key, scancode, isrepeat)
  if key == "space" then
    local i = character_i + 1
    local n = #characters
    if i <= n then
      character_i = i
    else
      character_i = 1
    end
  end
end
