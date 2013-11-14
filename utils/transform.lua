local vector = require "lib/hump/vector"
local Matrix = require "utils/matrix"
local Class = require "lib/hump/class"

local Transform = {}
Transform.__index = Transform

local Transform = Class{
    init = function(self, entity, parent)
        self.entity = entity
        self.position = vector.new(0, 0)
        self.rotation = 0
        self.children = {}
        self.parent = nil

        if parent ~= nil then
            self:setParent(parent)
        end
    end
}

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

function Transform:getChangeOfBasis()
    return Matrix.rotate(-self.rotation) * Matrix.translate(-self.position.x, -self.position.y)
end

function Transform:setRelative(parent)
    self:setMatrix(parent:getChangeOfBasis() * self:getAbsoluteMatrix())
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

function Transform:getAbsolutePosition()
    return self:getAbsoluteMatrix():getPosition()
end

function Transform:getAbsoluteRotation()
    return self:getAbsoluteMatrix():getRotation()
end

function Transform:getAbsoluteMatrix()
    if (self.parent == nil) then
        return self:getMatrix()
    else
        return self.parent:getAbsoluteMatrix() * self:getMatrix()
    end
end

function Transform:getLocalPosition()
    return self:getLocalMatrix():getPosition()
end

function Transform:getLocalRotation()
    return self:getLocalMatrix():getRotation()
end

function Transform:getLocalMatrix()
    if (self.parent == nil) then
        return Matrix.new()
    else
        return self.parent:getLocalMatrix() * self:getMatrix()
    end
end

function Transform:getAbsoluteMatrix()
    if (self.parent == nil) then
        return self:getMatrix()
    else
        return self.parent:getAbsoluteMatrix() * self:getMatrix()
    end
end

function Transform:getMatrix()
    return Matrix.translate(self.position.x, self.position.y) * Matrix.rotate(self.rotation)
end

function Transform:setMatrix(matrix)
    self.position = matrix:getPosition()
    self.rotation = matrix:getRotation()
end

function Transform:__tostring()
    local output = ''
    if self.parent ~= nil then
        output = 'Has Parent '
    end
    return output .. 'translate: ' .. self.position:__tostring() .. ' rotate: pi*' .. self.rotation / math.pi
end

return Transform
