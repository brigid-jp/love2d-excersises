local filesystem = require "love.filesystem"
local timer = require "love.timer"
local http = require "socket.http"
local ltn12 = require "ltn12"

local urls = {
  "http://brigid.jp/love2d-excersise/NotoSerifCJKjp-Regular.otf";
  "http://brigid.jp/love2d-excersise/mplus-1p-regular.ttf";
  -- "http://brigid.jp/love2d-excersise/";
}

local function save(file)
  return function (chunk, e)
    if chunk then
      print(#chunk)
      file:write(chunk)
    elseif e then
      error(e)
    end
    return true
  end
end

local ch = love.thread.getChannel "status"

for i = 1, #urls do
  local url = urls[i]
  local filename = url:match "[^/]+$" or "tmp.dat"
  ch:push { "fetching", url }
  local file = assert(filesystem.newFile(filename, "w"))
  http.request {
    url = url;
    sink = save(file);
  }
  file:close()
  ch:push { "fetched", url }
end
