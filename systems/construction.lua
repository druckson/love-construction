local transform = require "../utils/transform"
local vector = require "lib/hump/vector"
local entity = require "entity"
local Class = require "lib/hump/class"

local Construction = Class{
    init = function(self)
        self.objects = {}
    end
}

function Construction:add(object)
    object.construction = {}
    table.insert(self.objects, object)
end

function Construction:remove(object)
    for key, value in self.objects do
        if value == object then
            table.remove(self.objects, key)
        end
    end
end

function Construction:connect(o1, o2)
    assert(o1.construction ~= nil and o2.construction ~= nil,
           "Connect: wrong argument types (construction expected)")

    local locator = entity.new()

    -- Transform the first object in relation to the join point
    local o2BaseAncestor = o2.transform:getBaseAncestor()
    locator.transform:setMatrix(o2.transform:getAbsoluteMatrix())
    o2BaseAncestor:setParent(locator.transform)

    -- Move the join point (locator) to the second object
    locator.transform:setMatrix(o1.transform:getAbsoluteMatrix())

    -- Line it up
    locator.transform:rotate(math.pi)

    -- Remove the temporary locator
    o2BaseAncestor:removeParent()

    return locator
end

return Construction
