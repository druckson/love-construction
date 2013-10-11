local vector = require "lib/hump/vector"
local matrix = require "utils/matrix"

local Transform = {}
Transform.__index = Transform

function Transform.new(object, parent)
    local newTransform = setmetatable({
        object = object,
        position = vector.new(0, 0),
        rotation = 0,
        children = {},
        parent = nil
    }, Transform)

    if parent ~= nil then
        newTransform:setParent(parent)
    end

    return newTransform
end

function Transform:addChild(child)
    table.insert(self.children, child)
end

function Transform:removeChild(child)
    for key, value in pairs(self.children) do
        if value == child then
            table.remove(self.children, key)
        end
    end
end

function Transform:setAbsolute()
    self:setMatrix(self:getAbsoluteMatrix())
end

function Transform:setRelative(parent)
    local changeOfBasis = matrix.rotate(-parent.rotation) * matrix.translate(-parent.position.x, -parent.position.y)
    self:setMatrix(changeOfBasis * self:getAbsoluteMatrix())
end

function Transform:getBaseAncestor()
    if self.parent ~= nil then
        return self.parent:getBaseAncestor()
    else
        return self
    end
end

function Transform:removeParent()
    self:setAbsolute()
    self.parent:removeChild(self)
    self.parent = nil
end

function Transform:setParent(parent)
    if self.parent ~= nil then
        self:removeParent()
    end

    self:setRelative(parent)

    self.parent = parent
    self.parent:addChild(self)
end

function Transform:rotate(r)
    self:setRotation(self.rotation + r)
end

function Transform:move(x, y)
    self.position.x = self.position.x + x
    self.position.y = self.position.x + y
end

function Transform:setPosition(x, y)
    self.position = vector.new(x, y)
end

function Transform:setRotation(r)
    local r = ((2 * math.pi) + r) % (2 * math.pi)
    self.rotation = r
end

function Transform:getMatrix()
    return matrix.translate(self.position.x, self.position.y) * matrix.rotate(self.rotation)
end

function Transform:setMatrix(matrix)
    self.position = matrix * vector.new(0, 0)
    local newPosition = (matrix * vector.new(0, 1)) - self.position
    self:setRotation(-math.atan(newPosition.x / newPosition.y))
    if newPosition.y < 0 then self:rotate(math.pi) end
end

function Transform:getAbsoluteMatrix()
    if (self.parent == nil) then
        return self:getMatrix()
    else
        return self.parent:getAbsoluteMatrix() * self:getMatrix()
    end
end

function Transform:__tostring()
    local output = ''
    if self.parent ~= nil then
        output = 'Has Parent '
    end
    return output .. 'translate: ' .. self.position:__tostring() .. ' rotate: pi*' .. self.rotation / math.pi
end

return Transform
