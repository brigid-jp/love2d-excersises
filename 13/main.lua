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
  if not brigid then
    if bootloader:update() == "loaded" then
      brigid = bootloader.module
    end
  end
  if brigid then
    text[1] = "brigid version " .. brigid.get_version() .. "\n"
  end
end

function love.draw()
  local width = love.window.getMode()
  love.graphics.printf(table.concat(text), 50, 50, width - 100)
end
