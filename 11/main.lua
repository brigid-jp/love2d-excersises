local love = love
local g = love.graphics
local window = love.window

local mx
local my
local mbutton
local mistouch
local mpresses

function love.draw()
  local width = window.getMode()
  local text = love.system.getClipboardText()
  local state, percent, seconds = love.system.getPowerInfo()
  local os_string = love.system.getOS()
  local processor_count = love.system.getProcessorCount()
  local background_music = love.system.hasBackgroundMusic()

  local R, G, B, A = g.getColor()

  -- open url
  g.setColor(1, 0, 0)
  g.rectangle("fill", 50, 50, 100, 50)

  -- vibrate
  g.setColor(0, 0, 1)
  g.rectangle("fill", 150, 50, 100, 50)

  g.setColor(R, G, B, A)
  g.printf(([[
clipboard = %s
power_info
  state = %s
  percent = %s
  seconds = %s
os = %s
processor_count = %s
background_music = %s
mouse
  x = %s
  y = %s
  button = %s
  istouch = %s
  presses = %s
]]):format(
      text or "nil",
      state or "nil",
      percent or "nil",
      seconds or "nil",
      os_string,
      processor_count,
      background_music,
      mx or "nil",
      my or "nil",
      mbutton or "nil",
      mistouch or "nil",
      mpresses or "nil"), 50, 100, width - 100)
end

function love.mousepressed(x, y, button, istouch, presses)
  mx = x
  my = y
  mbutton = button
  mistouch = istouch
  mpresses = presses

  if 50 <= y and y < 100 then
    if 50 <= x and x < 150 then
      love.system.openURL("https://brigid.jp/love2d-excersise/")
      print "open url"
    elseif 150 <= x and x < 250 then
      love.system.vibrate()
      print "vibrate"
    end
  end
end
