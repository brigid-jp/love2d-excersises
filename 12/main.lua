local love = love
local ffi = require "ffi"
local brigid

pcall(function () brigid = require "brigid" end)

local text = {}

local function write(...)
  local data = {...}
  for i = 1, #data do
    text[#text + 1] = data[i]
  end
end

local function dump(data)
  for i = 1, #data, 8 do
    write(love.data.encode("string", "hex", data:sub(i, i + 7)), "\n")
  end
end

function love.load()
  write("version ", love.getVersion(), "\n")
  write("ffi ", tostring(ffi), "\n")
  write("brigid ", tostring(brigid), "\n")
  write("os ", love.system.getOS(), "\n")
  write("crequirepath ", love.filesystem.getCRequirePath(), "\n")
  write("savedirectory ", love.filesystem.getSaveDirectory(), "\n")
  write("source ", love.filesystem.getSource(), "\n")
  write("sourcebasedirectory ", love.filesystem.getSourceBaseDirectory(), "\n")
  write("userdirectory ", love.filesystem.getUserDirectory(), "\n")
  write("workingdirectory ", love.filesystem.getWorkingDirectory(), "\n")
  local chunk = string.dump(function () end)
  dump(chunk)
  if chunk:sub(1, 3) == "\27LJ" then
    write "LuaJIT\n"
  end
  write("jit.version ", jit.version, "\n")
  write("jit.version_num ", jit.version_num, "\n")
  write("jit.os ", jit.os, "\n")
  write("jit.arch ", jit.arch, "\n")
end

function love.draw()
  local width = love.window.getMode()
  love.graphics.printf(table.concat(text), 50, 50, width - 100)
end
