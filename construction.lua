local vector = require "../hump/vector"

local Construction = {
    objects = {}
}

function Construction:add(object)
    object.construction = {}
    table.insert(self.objects, object)
end

function getRelativePosition(object)
    assert(object.transform ~= nil)

    if object.transform.parent == nil then
        return vector.new(0, 0)
    else
        return object.transform.position + getRelativePosition(object.transform.parent)
    end
end

function getMaximalAncestor(object)
    assert(object.transform ~= nil)
    
    if object.transform.parent == nil then
        return object
    else
        return getMaximalAncestor(object.transform.parent)
    end
end

function Construction:connect(o1, o2)
    assert(o1.construction ~= nil and o2.construction ~= nil,
           "Connect: wrong argument types (construction expected)")

    local o1rel = getRelativePosition(o1)
    local o2rel = getRelativePosition(o2)

    local o1par = getMaximalAncestor(o1)
    local o2par = getMaximalAncestor(o2)

    local dist = o1rel:len() + o2rel:len()
    local direction = o1rel:normalized()
    direction = vector.new(math.sin() -
                           math.cos(),
                           math.cos() +
                           math.sin())

    o2par.transform.position = o1par.transform.position + (direction * dist)
end

return Construction
