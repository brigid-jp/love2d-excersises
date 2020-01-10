local unpack = table.unpack or unpack

local g = love.graphics

local font
local font32
local emoji
local emojic
local thread

local color_emoji_images = {
  0x2764,  -- red heart
  0x1F495, -- two hearts
  0x1F496, -- sparkling heart
  0x1F48B, -- kiss mark
}

function love.load()
  thread = love.thread.newThread "thread.lua"
  thread:start(love.timer.getTime())
end

function love.update(dt)
  if not thread:isRunning() then
    local channel = love.thread.getChannel "brigid_fontloader"
    while true do
      local result = channel:pop()
      if not result then
        break
      end
      local result, message = unpack(result)
      if result then
        local s = love.timer.getTime()
        font = g.newFont(message)
        local t = love.timer.getTime()
        print("newFont", t - s)
      end
    end
  end
  if font and not emoji then
    -- emoji = assert(g.newFont(assert(love.font.newRasterizer("NotoColorEmoji.ttf", 64))))
    emoji = assert(g.newFont(assert(love.font.newRasterizer("NotoEmoji-Regular.ttf"))))
    -- emoji = assert(love.graphics.newImageFont("emoji_u2764.png", string.char(0xE2, 0x9D, 0xA4)))
    -- emoji = assert(love.graphics.newImageFont("emoji.png", " " .. string.char(0xE2, 0x9D, 0xA4)))
    emojic = assert(g.newFont(love.font.newImageRasterizer("emoji.png",
      " " .. string.char(0xE2, 0x9D, 0xA4) .. string.char(0xF0, 0x9F, 0x92, 0x8B),
      0, 32/16)))
  end
end

function love.draw()
  local x, y, w, h = love.window.getSafeArea()
  if font then
    g.printf("M+フォントがロードされました", font, x + 24, y + 24, w - 48)
    if emoji then
      g.printf("Noto絵文字フォントがロードされました", font, x + 24, y + 42, w - 48)
      g.printf("んほぉ", font, x + 24, y + 60, w - 48)
      g.printf(string.char(0xE2, 0x9D, 0xA4), emoji, x + 60, y + 60, w - 80)
      g.printf("らめぇ", font, x + 24, y + 78, w - 48)
      g.printf(string.char(0xE2, 0x9D, 0xA4), emoji, x + 60, y + 78, w - 80)
      g.printf("んほぉ", font, x + 24, y + 96, w - 48)
      g.printf(string.char(0xE2, 0x9D, 0xA4), emojic, x + 60, y + 96, w - 80)
      g.printf("らめぇ", font, x + 24, y + 114, w - 48)
      g.printf(string.char(0xE2, 0x9D, 0xA4), emojic, x + 60, y + 114, w - 80)
    end
  else
    g.printf("loading font...", x + 24, y + 24, w - 48)
  end
end
