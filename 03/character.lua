local g = love.graphics
local isDown = love.keyboard.isDown

local class = {}
local metatable = { __index = class }

local function construct(filename, x, y)
  local image = g.newImage(filename)

  local sw, sh = image:getDimensions()
  local tiles = {
    -- front (down)
    g.newQuad( 0, 0, 48, 48, sw, sh);
    g.newQuad(48, 0, 48, 48, sw, sh);
    g.newQuad(96, 0, 48, 48, sw, sh);

    -- left
    g.newQuad( 0, 48, 48, 48, sw, sh);
    g.newQuad(48, 48, 48, 48, sw, sh);
    g.newQuad(96, 48, 48, 48, sw, sh);

    -- right
    g.newQuad( 0, 96, 48, 48, sw, sh);
    g.newQuad(48, 96, 48, 48, sw, sh);
    g.newQuad(96, 96, 48, 48, sw, sh);

    -- back (up)
    g.newQuad( 0, 144, 48, 48, sw, sh);
    g.newQuad(48, 144, 48, 48, sw, sh);
    g.newQuad(96, 144, 48, 48, sw, sh);
  }

  return {
    x = x or 0;
    y = y or 0;
    orientation = 1;
    animation = 2;
    i = 2;
    image = image;
    tiles = tiles;
  }
end

function class:update(dt, active)

  local animation_speed = 4
  self.animation = self.animation + animation_speed * dt

  if active then
    local speed = 144
    local x = self.x
    local y = self.y
    local orientation = self.orientation

    if isDown "up" then
      y = y - speed * dt
      orientation = 4
    end

    if isDown "right" then
      x = x + speed * dt
      orientation = 3
    end

    if isDown "down" then
      y = y + speed * dt
      orientation = 1
    end

    if isDown "left" then
      x = x - speed * dt
      orientation = 2
    end

    self.x = x
    self.y = y
    self.orientation = orientation
  end
end

function class:draw()
  local quad = self.tiles[(self.orientation - 1) * 3 + math.floor(self.animation) % 3 + 1]
  g.draw(self.image, quad, self.x, self.y)
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(construct(...), metatable)
  end;
})
