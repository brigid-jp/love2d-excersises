local ffi = require "ffi"

local love = love
local g = love.graphics
local window = love.window

local thread
local buffer = { "false\n" }
local font

local version
local codename
local sdl_version

function love.load()
  local major, minor, revision
  major, minor, revision, codename = love.getVersion()
  version = ("%d.%d.%d"):format(major, minor, revision)

  ffi.cdef [[
typedef struct {
  uint8_t major;
  uint8_t minor;
  uint8_t patch;
} SDL_version;

void SDL_GetVersion(SDL_version* ver);
]]

  local a, b = pcall(function ()
    local ver = ffi.new "SDL_version"
    ffi.C.SDL_GetVersion(ver)
    return ver
  end)

  local sdl_ver = {
    major = 0;
    minor = 0;
    patch = 0;
  }

  if a then
    sdl_ver = b
  else
    print(b)
    local a, b = pcall(function ()
      local ver = ffi.new "_SDL_version"
      ffi.C.SDL_GetVersion(ver)
      return ver
    end)
    if a then
      sdl_ver = b
    else
      print(b)
    end
  end

  sdl_version = ("%d.%d.%d"):format(sdl_ver.major, sdl_ver.minor, sdl_ver.patch)
end

function love.draw()
  local width = window.getMode()
  g.printf(([[
version=%s
codename=%s
sdl_version=%s
]]):format(version, codename, sdl_version), 0, 50, width)
end
