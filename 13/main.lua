local brigid_bootloader = require "brigid_bootloader"

local brigid
local bootloader
local text = {
  "loading brigid...\n"
}

function love.load()
  bootloader = brigid_bootloader()
end

function love.update(dt)
  if brigid == nil then
    bootloader:update()
    if bootloader.state == "loaded" then
      brigid = bootloader.module
    elseif bootloader.state == "error" then
      brigid = false
    end
    text[1] = "brigid " .. bootloader.state .. "\n"
  end
  if type(brigid) == "table" then
    text[2] = "brigid version " .. brigid.get_version() .. "\n"
  end
end

function love.draw()
  local width = love.window.getMode()
  love.graphics.printf(table.concat(text), 50, 50, width - 100)
end
