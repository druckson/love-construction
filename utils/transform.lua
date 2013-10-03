local vector = require "../../hump/vector"

local Transform = {}

function Transform.new(position, r)
    local newTransform = {
        position = position or vector.new(0, 0),
        rotation = r or 0
    }

    return setmetatable(newTransform, Transform)
end

function Transform:setParent(parent)
    local absolute = self:getAbsolute()
    parent
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
