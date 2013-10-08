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
    table.remove(self.children, child)
end

function Transform:setAbsolute()
    self:setMatrix(self:getAbsoluteMatrix())
end

function Transform:setRelative(parent)
    local changeOfBasis = matrix.rotate(-parent.rotation) * matrix.translate(-parent.position.x, -parent.position.y) 
    self:setMatrix(changeOfBasis * self:getMatrix())
end

function Transform:setParent(parent)
    self:setAbsolute()

    if self.parent ~= nil then
        self.parent:removeChild(self)
        self:setRelative(parent)
    end

    self.parent = parent
    self.parent:addChild(self)
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

function Transform:setMatrix(matrix)
    self.rotation = math.acos(matrix[1][1])
    self.position = vector.new(matrix[3][1], matrix[3][2])
end

function Transform:getAbsoluteMatrix()
    if (self.parent == nil) then
        return self:getMatrix()
    else
        return self.parent:getAbsoluteMatrix() * self:getMatrix()
    end
end

function Transform:__tostring()
    return 'translate: ' .. self.position:__tostring() .. ' rotate: pi*' .. self.rotation / math.pi
end

return setmetatable(Transform, {__call = Transform.new})
