local love = love
local g = love.graphics

local mesh
local shader
local rotation
local transform

local function make_triangle(vertices, ax, ay, az, bx, by, bz, cx, cy, cz)
  local ux = bx - ax
  local uy = by - ay
  local uz = bz - az
  local vx = cx - ax
  local vy = cy - ay
  local vz = cz - az
  local x = uy * vz - uz * vy
  local y = uz * vx - ux * vz
  local z = ux * vy - uy * vx
  local d = math.sqrt(x * x + y * y + z * z)
  x = x / d
  y = y / d
  z = z / d
  local n = #vertices
  vertices[n + 1] = { ax, ay, az, x, y, z }
  vertices[n + 2] = { bx, by, bz, x, y, z }
  vertices[n + 3] = { cx, cy, cz, x, y, z }
end

local function make_icosahedron(a)
  local b = a * (1 + math.sqrt(5)) * 0.5

  local points = {
    { 0, -a, b };
    { b, 0, a };
    { b, 0, -a };
    { -b, 0, -a };
    { -b, 0, a };
    { -a, b, 0 };
    { a, b, 0 };
    { a, -b, 0 };
    { -a, -b, 0 };
    { 0, -a, -b };
    { 0, a, -b };
    { 0, a, b };
  }

  local faces = {
    { 2, 3, 7 };
    { 2, 8, 3 };
    { 4, 5, 6 };
    { 5, 4, 9 };
    { 7, 6, 12 };
    { 6, 7, 11 };
    { 10, 11, 3 };
    { 11, 10, 4 };
    { 8, 9, 10 };
    { 9, 8, 1 };
    { 12, 1, 2 };
    { 1, 12, 5 };
    { 7, 3, 11 };
    { 2, 7, 12 };
    { 4, 6, 11 };
    { 6, 5, 12 };
    { 3, 8, 10 };
    { 8, 2, 1 };
    { 4, 10, 9 };
    { 5, 9, 1 };
  }

  local vertices = {}
  for i = 1, #faces do
    local face = faces[i]
    local a = points[face[1]]
    local b = points[face[2]]
    local c = points[face[3]]
    make_triangle(vertices, a[1], a[2], a[3], b[1], b[2], b[3], c[1], c[2], c[3])
  end

  return vertices
end

function love.load()
  mesh = g.newMesh({
    { "VertexPosition", "float", 3 };
    { "NormalAttribute", "float", 3 };
  }, make_icosahedron(100), "triangles", "static")

  shader = g.newShader([[
    varying vec4 Normal;

    vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord) {
      // return vec4(1, 1, 1, 1);
      return vec4(Normal.xyz, 0.5);
    }
  ]], [[
    attribute vec4 NormalAttribute;
    varying vec4 Normal;

    vec4 position(mat4 transform_projection, vec4 vertex_position) {
      Normal = NormalAttribute;
      return transform_projection * vertex_position;
    }

  ]])

  rotation = love.math.newTransform()

  transform = love.math.newTransform()
  transform:translate(200, 200)

  local m = { transform:getMatrix() }
  m[11] = 0.01

  transform:setMatrix(unpack(m))
end

function love.draw()
  g.replaceTransform(transform)
  g.applyTransform(rotation)
  g.setShader(shader)
  g.draw(mesh)
end

local x = 0

function love.keypressed(key)
  if key == "up" then
  end
  if key == "down" then
  end
  if key == "right" then
    x = x + 1
    local c = math.cos(0.05 * x)
    local s = math.sin(0.05 * x)
    rotation:setMatrix(
        c, 0, s, 0,
        0, 1, 0, 0,
        -s, 0, c, 0,
        0, 0, 0, 1)
  end
  if key == "left" then
  end
end
