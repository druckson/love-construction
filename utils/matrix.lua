local vector = require "lib/hump/vector"

local Matrix = {}

function Matrix.new()
    local newMatrix = {
        {1, 0, 0},
        {0, 1, 0},
        {0, 0, 1}
    }

    return setmetatable(newMatrix, Matrix)
end

function Matrix:getRow(y)
    return {self[0][y], self[1][y], self[2][y]}
end

function Matrix:getColumn(x)
    return {self[x][0], self[x][1], self[x][2]}
end

function linearCombine(v1, v2)
    local total = 0
    for i=0,2 do
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
            {combine(0, 0), combine(1, 0), combine(2, 0)},
            {combine(0, 1), combine(1, 1), combine(2, 1)},
            {combine(0, 2), combine(1, 2), combine(2, 2)}
        })
    elseif (isVector(other)) then
        return vector.new(self[0][0]*other.x + self[1][0]*other.x + self[2][0]*other.x,
                          self[0][1]*other.y + self[1][1]*other.y + self[2][1]*other.y)
    end
end

return setmetatable({new = Matrix.new}, {__call = Matrix.new})
