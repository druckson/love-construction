local vector = require "lib/hump/vector"
local matrix = require "utils/matrix"

local Transform = {}
Transform.__index = Transform

function Transform.new()
    local newTransform = {
        position = vector.new(0, 0),
        rotation = 0
    }

    return setmetatable(newTransform, Transform)
end

function Transform:setPosition(x, y)
    self.position = vector.new(x, y)
end

function Transform:setRotation(r)
    self.rotation = r
end

function Transform:getMatrix()
    return matrix.translate(self.position.x, self.position.y) * matrix.rotate(self.rotation)
end

function Transform:getAbsoluteTransformation()
    if (self.parent == nil) then
        return self:getMatrix()
    else
        return getAbsolute(self.parent) * self:getMatrix()
    end
end

return setmetatable(Transform, {__call = Transform.new})
