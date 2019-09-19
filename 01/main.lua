local pcall = pcall

local love = love
local g = love.graphics
local window = love.window

local font
local text = [[
メロスは激怒した。必ず、かの邪智暴虐の王を除かなければならぬと決意した。メロスには政治がわからぬ。メロスは、村の牧人である。笛を吹き、羊と遊んで暮して来た。けれども邪悪に対しては、人一倍に敏感であった。きょう未明メロスは村を出発し、野を越え山越え、十里はなれた此のシラクスの市にやって来た。
]]

function love.load()
  font = g.newFont("NotoSerifCJKjp-Regular.otf", 24)
  local width, height, flags = window.getMode()
  window.setMode(width, height, {
    resizable = true;
  })
end

function love.draw()
  local width, height, flags = window.getMode()
  g.printf(text, font, 32, 32, width - 64)
end

function love.keypressed(key)
end

function love.keyreleased(key)
end

function love.textedited(text, start, length)
end

function love.textinput(text)
end
