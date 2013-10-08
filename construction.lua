local transform = require"../utils/transform" local vector = require "lib/hump/vector"

local Construction = {
    objects = {}
}

function Construction:add(object)
    object.construction = {}
    table.insert(self.objects, object)
end

function Construction:connect(o1, o2)
    assert(o1.construction ~= nil and o2.construction ~= nil,
           "Connect: wrong argument types (construction expected)")

    local locator = transform.new()
    locator:setMatrix(o2.transform:getAbsoluteMatrix())

    local o2BaseAncestor = o2.transform:getBaseAncestor()
    o2BaseAncestor:setParent(locator)
    locator:setMatrix(o1.transform:getAbsoluteMatrix())
    locator:rotate(math.pi)
    o2BaseAncestor:removeParent()
end

return Construction
