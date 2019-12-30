local brigid
local brigid_loader = require "brigid_loader"

local loader
local text = {}

function love.load()
  loader = brigid_loader()
end

function love.update(dt)
  if loader:update() == "loaded" then
    brigid = loader.module
  end
  text[1] = loader.state .. "\n"
  text[2] = tostring(brigid)
end

function love.draw()
  local width = love.window.getMode()
  love.graphics.printf(table.concat(text), 50, 50, width - 100)
end
