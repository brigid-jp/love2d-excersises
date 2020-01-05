local brigid_bootloader = require "brigid_bootloader"

local brigid
local bootloader
local text = {
  "brigid loading...\n"
}

function love.load()
  bootloader = brigid_bootloader()
end

function love.update(dt)
  if brigid == nil then
    local state = bootloader:update()
    if state == "loaded" then
      brigid = bootloader.module
      text[1] = "brigid loaded\n"
      text[2] = "brigid " .. brigid.get_version() .. "\n"
    elseif bootloader.state == "error" then
      brigid = false
      text[1] = "brigid load error\n"
      text[2] = bootloader.message .. "\n"
    end
  end
end

function love.draw()
  local width = love.window.getMode()
  love.graphics.printf(table.concat(text), 50, 50, width - 100)
end
