local vector = require "lib/hump/vector"
local matrix = require "utils/matrix"

local Transform = {}
Transform.__index = Transform

function Transform.new(position, r)
    local newTransform = {
        position = position or vector.new(0, 0),
        rotation = r or 0
    }

    return setmetatable(newTransform, Transform)
end

function Transform:setPosition(x, y)
    self.position = vector.new(x, y)
end

function Transform:setRotation(r)
    self.rotation = r
end

function Transform:getAbsolute()
    if (self.parent == nil) then
        return self
    else
        return getAbsolute(self.parent) * self
    end
end

function Transform.__mul(t1, t2)
    
end

return setmetatable({}, {__call = Transform.new})
