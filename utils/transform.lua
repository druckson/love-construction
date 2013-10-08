local vector = require "lib/hump/vector"
local matrix = require "utils/matrix"

local Transform = {}
Transform.__index = Transform

function Transform.new(object, parent)
    local newTransform = {
        object = object,
        position = vector.new(0, 0),
        rotation = 0,
        children = {},
        parent = nil
    }

    if parent ~= nil then
        self:setParent(parent)
    end

    return setmetatable(newTransform, Transform)
end

function Transform:addChild(child)
    table.insert(self.children, child)
end

function Transform:removeChild(child)
    table.remove(self.children, child)
end

function Transform:setParent(parent)
    if self.parent ~= nil then
        self.parent:removeChild(self)
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

function Transform:getAbsoluteMatrix()
    if (self.parent == nil) then
        return self:getMatrix()
    else
        return self.parent:getAbsoluteTransformation() * self:getMatrix()
    end
end

function Transform:__tostring()
    return 'translate: ' .. self.position .. ' rotate: ' .. self.rotation
end

return setmetatable(Transform, {__call = Transform.new})
