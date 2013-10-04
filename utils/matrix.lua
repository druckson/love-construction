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
        {math.cos(r), -math.sin(r), 0},
        {math.sin(r),  math.cos(r), 0},
        {          0,            0, 1}
    })
end

function Matrix.translate(x, y)
    return Matrix.new({
        {1, 0, 0},
        {0, 1, 0},
        {x, y, 1}
    })
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

function Matrix.__mul(self, other)
    if (getmetatable(other) == Matrix) then
        local function combine(x, y)
            return linearCombine(self:getRow(x), other:getColumn(y))
        end

        return Matrix.new({
            {combine(1, 1), combine(2, 1), combine(3, 1)},
            {combine(1, 2), combine(2, 2), combine(3, 2)},
            {combine(1, 3), combine(2, 3), combine(3, 3)}
        })
    elseif (vector.isvector(other)) then
        return vector.new(self[1][1]*other.x + self[2][1]*other.y + self[3][1],
                          self[1][2]*other.x + self[2][2]*other.y + self[3][2])
    end
    assert(false, "Expected matrix or vector in multiplication")
end

return setmetatable(Matrix, {__call = Matrix.new})
