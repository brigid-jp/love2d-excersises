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
    i = 2;
    image = image;
    tiles = tiles;
  }
end

function class:update(dt)
  local speed = 144
  local x = self.x
  local y = self.y
  local i = self.i

  if isDown "up" then
    y = y - speed * dt
    i = 11
  end

  if isDown "right" then
    x = x + speed * dt
    i = 8
  end

  if isDown "down" then
    y = y + speed * dt
    i = 2
  end

  if isDown "left" then
    x = x - speed * dt
    i = 5
  end

  self.x = x
  self.y = y
  self.i = i
end

function class:draw()
  g.draw(self.image, self.tiles[self.i], self.x, self.y)
end

return setmetatable(class, {
  __call = function (_, ...)
    return setmetatable(construct(...), metatable)
  end;
})
