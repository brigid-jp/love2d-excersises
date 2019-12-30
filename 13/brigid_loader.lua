local love = {
  data = require "love.data";
  filesystem = require "love.filesystem";
  system = require "love.system";
  thread = require "love.thread";
}
local http = require "socket.http"
local ltn12 = require "ltn12"

local ch = love.thread.getChannel "brigid_loader"

local os = love.system.getOS()
local arch = jit.arch
local url
local filename
local sha256

local modules = {
  ["OS X"] = {
    url = "http://brigid.jp/pub/brigid-1.4-osx-x64.so";
    size = 160744;
    sha256 = "\242\057\242\218\082\165\192\062\114\001\160\220\009\149\227\224\110\209\012\089\237\228\162\041\229\240\088\086\009\170\200\062";
  };
  ["Windows"] = {
    url = "http://brigid.jp/pub/brigid-1.4-win-x64.dll";
    size = 109056;
    sha256 = "\159\033\224\253\071\249\141\083\235\018\139\219\050\160\173\053\103\023\021\031\227\085\043\216\016\198\024\223\132\029\152\114";
  };
}

local module
if arch == "x64" then
  module = modules[love.system.getOS()]
end

if not module then
  ch:push "error"
  return
end

local filename
if module.url:find "%.dll$" then
  filename = "brigid.dll"
else
  filename = "brigid.so"
end

local new_filename = filename .. ".new"

http.request {
  url = module.url;
  sink = ltn12.sink.file(io.open(new_filename, "wb"));
}

local hash = love.data.hash("sha256", assert(love.filesystem.newFileData(new_filename)))
if hash == module.sha256 then
  love.filesystem.write(filename, love.filesystem.read(new_filename))
  love.filesystem.remove(new_filename)
  ch:push "ok"
else
  love.filesystem.remove(new_filename)
  ch:push "error"
end
