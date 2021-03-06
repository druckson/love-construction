local vector = require "lib/hump/vector"
local math = require "math"

local Matrix = {}
Matrix.__index = Matrix

function Matrix.new(value)
    local newMatrix = value or {
        {1, 0, 0},
        {0, 1, 0},
        {0, 0, 1}
    }

    return setmetatable(newMatrix, Matrix)
end

function Matrix.scale(s)
    return Matrix.new({
        {s, 0, 0},
        {0, s, 0},
        {0, 0, 1}
    })
end

function Matrix.rotate(r)
    return Matrix.new({
        { math.cos(r), math.sin(r), 0},
        {-math.sin(r), math.cos(r), 0},
        {           0,           0, 1}
    })
end

function Matrix.translate(x, y)
    return Matrix.new({
        {1, 0, 0},
        {0, 1, 0},
        {x, y, 1}
    })
end

function Matrix:getRotation()
    local position = self:getPosition()
    local newPosition = (self * vector.new(0, 1)) - position
    local rotation = -math.atan(newPosition.x / newPosition.y)
    if newPosition.y < 0 then rotation = rotation + math.pi end

    return rotation
end

function Matrix:getScale()
    local newPosition = self * vector.new(0, 1)
    return newPosition:len()
end

function Matrix:getPosition()
    return self * vector.new(0, 0)
end

function Matrix:getRow(y)
    return {self[1][y], self[2][y], self[3][y]}
end

function Matrix:getColumn(x)
    return {self[x][1], self[x][2], self[x][3]}
end

local function linearCombine(v1, v2)
    local total = 0
    for i=1,3 do
        total = total + v1[i]*v2[i]
    end
    return total
end

function Matrix:__mul(other)
    if (getmetatable(other) == Matrix) then
        local function combine(x, y)
            return linearCombine(self:getRow(x), other:getColumn(y))
        end

        return Matrix.new({
            {combine(1, 1), combine(2, 1), combine(3, 1)},
            {combine(1, 2), combine(2, 2), combine(3, 2)},
            {combine(1, 3), combine(2, 3), combine(3, 3)}
        })
    else
        return vector.new(self[1][1]*other.x + self[2][1]*other.y + self[3][1],
                          self[1][2]*other.x + self[2][2]*other.y + self[3][2])
    end
    assert(false, "Expected matrix or vector in multiplication")
end

function Matrix:__tostring()
    local string = ''
    for _, row in pairs(self) do
        local line = ''
        for _, element in pairs(row) do
            line = line .. ' ' .. element
        end
        string = string .. '{' .. line .. '}' .. '\n'
    end

    return string
end

return Matrix
