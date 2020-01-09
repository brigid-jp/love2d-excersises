local love = {
  data = require "love.data";
  font = require "love.font";
  filesystem = require "love.filesystem";
  thread = require "love.thread";
  timer = require "love.timer";
}
local http = require "socket.http"
local ltn12 = require "ltn12"

local info = {
  url = "http://brigid.jp/pub/mplus-TESTFLIGHT-063a/mplus-1mn-light.ttf";
  filename = "mplus-1mn-light.ttf";
  size = 1655680;
  sha256 = "\034\128\177\205\031\119\013\144\179\214\072\088\137\142\089\156\238\202\049\011\087\071\004\149\086\050\048\100\162\133\121\058";
}
info.path = love.filesystem.getSaveDirectory() .. "/" .. info.filename

local s = ...

local result, message = pcall(function ()
  local t = love.timer.getTime()
  print("thread:start", t - s)

  love.filesystem.write("dummy.dat", "dummy")

  local s = love.timer.getTime()
  assert(http.request {
    url = info.url;
    sink = ltn12.sink.file(io.open(info.path, "w"));
  })
  local t = love.timer.getTime()
  print("http.request", t - s)

  local fileinfo = assert(love.filesystem.getInfo(info.filename))
  assert(fileinfo.size == info.size)
  assert(love.data.hash("sha256", assert(love.filesystem.newFileData(info.filename))) == info.sha256)

  local s = love.timer.getTime()
  local rasterizer = assert(love.font.newRasterizer(info.filename))
  local t = love.timer.getTime()
  print("newRasterizer", t - s)
  -- return rasterizer

  return info.filename
end)

local channel = love.thread.getChannel "brigid_fontloader"
channel:push { result, message }
