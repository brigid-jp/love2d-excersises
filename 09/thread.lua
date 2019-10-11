local data = require "love.data"
local filesystem = require "love.filesystem"
local timer = require "love.timer"
local http = require "socket.http"
local ltn12 = require "ltn12"

local urls = {
  -- "http://brigid.jp/love2d-excersise/NotoSerifCJKjp-Regular.otf";
  "http://brigid.jp/love2d-excersise/mplus-1p-regular.ttf";
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
  local d = filesystem.newFileData(filename)
  local sha256 = data.encode("string", "hex", data.hash("sha256", d))
  ch:push { "fetched", filename, sha256 }
end
