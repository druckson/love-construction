local vector = require "lib/hump/vector"

local Matrix = {}
Matrix.__index = Matrix

function Matrix.new()
    local newMatrix = {
        {1, 0, 0},
        {0, 1, 0},
        {0, 0, 1}
    }

    return setmetatable(newMatrix, Matrix)
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
    local function combine(x, y)
        return linearCombine(self:getRow(x), other:getColumn(y))
    end

    if (getmetatable(other) == Matrix) then
        return Matrix.new({
            {combine(1, 1), combine(2, 1), combine(3, 1)},
            {combine(1, 2), combine(2, 2), combine(3, 2)},
            {combine(1, 3), combine(2, 3), combine(3, 3)}
        })
    elseif (isVector(other)) then
        return vector.new(self[1][1]*other.x + self[2][1]*other.x + self[3][1]*other.x,
                          self[1][2]*other.y + self[2][2]*other.y + self[3][2]*other.y)
    end
end

return setmetatable({new = Matrix.new}, {__call = Matrix.new})
