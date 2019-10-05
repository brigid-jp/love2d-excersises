local love = love
local g = love.graphics
local window = love.window
local fs = love.filesystem

local font
local edited
local buffer = {}

local function debug(...)
  assert(fs.append("debug.log", table.concat({...}, "\t") .. "\n"))
end

function love.load()
  local width, height = window.getMode()
  debug("load", width, height)
end

function love.quit()
end

function love.update(dt)
end

function love.resize(width, height)
  debug("resize", width, height)
end

function love.draw()
end

function love.keypressed(key)
  debug("keypressed", key)
end

function love.keyreleased(key)
  debug("keyreleased", key)
end

function love.textedited(text, start, length)
  debug("textedited", text, start, length)
end

function love.textinput(text)
  debug("textinput", text)
end

function love.mousepressed(x, y, button, istouch, presses)
end
