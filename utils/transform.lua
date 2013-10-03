local vector = require "../../hump/vector"

local Transform = {}

function Transform.new(x, y, r)
    local newTransform = {
        position = vector.new(x, y),
        rotation = r
    }

    return setmetatable(newTransform, Transform)
end

function Transform:setParent(parent)
    
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
