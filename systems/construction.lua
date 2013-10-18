local transform = require "../utils/transform"
local vector = require "lib/hump/vector"
local entity = require "entity"
local Class = require "lib/hump/class"

local Construction = Class{
    init = function(self)
        self.entities = {}
    end
}

function Construction:setup(engine)
    local construction = self
    engine.registry:register("init_entity", function(...)
        construction:init_entity(...)
    end)
    engine.registry:register("remove_entity", function(...)
        construction:remove_entity(...)
    end)
end

function Construction:init_entity(entity, object)
    entity.construction = {}
    table.insert(self.entities, entity)
end

function Construction:remove_entity(entity)
    for key, value in self.entities do
        if value == entity then
            table.remove(entity, "construction")
            table.remove(self.entities, key)
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
