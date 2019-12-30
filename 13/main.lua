local brigid
local brigid_loader
local brigid_loader_state

pcall(function () brigid = require "brigid" end)

local text = {}

function love.update(dt)
  if brigid then
    text[1] = brigid.get_version() .. "\n"
  else
    if brigid_loader then
      if not brigid_loader_state then
        local ch = love.thread.getChannel "brigid_loader"
        local v = ch:pop()
        if v then
          text[#text + 1] = v .. "\n"
          if v == "ok" then
            pcall(function () brigid = require "brigid" end)
          end
          brigid_loader_state = 1
        end
      end
    else
      brigid_loader = love.thread.newThread "brigid_loader.lua"
      brigid_loader:start()
    end
  end
end

function love.draw()
  local width = love.window.getMode()
  love.graphics.printf(table.concat(text), 50, 50, width - 100)
end
