local vector = require "../hump/vector"

local Transform = {
    objects = {}
}

function Transform:add(object, x, y, r, parent)
    object.transform = {
        position = vector.new(x, y),
        rotation = r,
        children = {}
    }
    if parent and table[parent] ~= nil then
        self:addChild(parent, object)
    end
    table.insert(self.objects, object)
end

function Transform:addChild(parent, child)
    if child.parent ~= nil then
        table.remove(child.parent.children, child)
    end
    child.transform.parent = parent
    table.insert(parent.children, child)
end

function Transform:remove(object)
    table.remove(self.objects, object)
end

function Transform:getObjects()
    return self.objects
end

return Transform
