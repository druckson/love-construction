local transform = require"../utils/transform" local vector = require "lib/hump/vector"
local entity = require "entity"

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

    local locator = entity.new()

    local o2BaseAncestor = o2.transform:getBaseAncestor()
    locator.transform:setMatrix(o2.transform:getAbsoluteMatrix())
    o2BaseAncestor:setParent(locator.transform)
    locator.transform:setMatrix(o1.transform:getAbsoluteMatrix())
    locator.transform:rotate(math.pi)
    o2BaseAncestor:removeParent()

    return locator
end

return Construction
