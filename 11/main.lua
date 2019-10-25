local love = love
local g = love.graphics
local window = love.window

function love.draw()
  local width = window.getMode()
  local text = love.system.getClipboardText()
  local state, percent, seconds = love.system.getPowerInfo()
  local os_string = love.system.getOS()
  local processor_count = love.system.getProcessorCount()
  local background_music = love.system.hasBackgroundMusic()

  g.printf(([[
clipboard = %s
power_info
  state = %s
  percent = %s
  seconds = %s
os = %s
processor_count = %s
background_music = %s
]]):format(
      text or "nil",
      state or "nil",
      percent or "nil",
      seconds or "nil",
      os_string,
      processor_count,
      background_music), 50, 50, width - 100)
end
