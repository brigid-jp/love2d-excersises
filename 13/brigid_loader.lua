local data = require "love.data"
local filesystem = require "love.filesystem"
local system = require "love.system"
local thread = require "love.thread"
local http = require "socket.http"

local ch = thread.getChannel "brigid_loader"

local os = system.getOS()
local arch = jit.arch
local url
local filename
local sha256

if os == "OS X" then
  if arch == "x64" then
    url = "http://brigid.jp/pub/brigid-1.4-osx-x64.so"
    filename = "brigid.so"
    sha256 = "f239f2da52a5c03e7201a0dc0995e3e06ed10c59ede4a229e5f0585609aac83e"
  end
elseif os == "Windows" then
  if arch == "x64" then
    url = "http://brigid.jp/pub/brigid-1.4-win-x64.dll"
    filename = "brigid.dll"
    sha256 = "9f21e0fd47f98d53eb128bdb32a0ad356717151fe3552bd810c618df841d9872"
  end
end

if not url then
  ch:push "error"
  return
end

local file = assert(filesystem.newFile(filename, "w"))

http.request {
  url = url;
  sink = function (chunk, e)
    if chunk then
      file:write(chunk)
    elseif e then
      error(e)
    end
    return true
  end;
}

file:close()

local hash = data.encode("string", "hex", data.hash("sha256", assert(filesystem.newFileData(filename))))
if hash == sha256 then
  ch:push "ok"
else
  filesystem.remove(filename)
  ch:push "error"
end
