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
    self.engine = engine
    local construction = self
    engine.messaging:register("begin_contact", function(a, b, collision)
        local entity1 = a:getUserData()
        local entity2 = b:getUserData()
        if entity1.construction and entity2.construction and
            not entity1.construction.connected and not entity2.construction.connected then
            engine.messaging:emit("connect", entity1, entity2)
        end
        return true
    end)

    engine.messaging:register("end_contact", function(a, b, collision)
        --local entity1 = a:getUserData()
        --local entity2 = b:getUserData()
        --if entity1.construction and entity2.construction and
        --    entity1.construction.connected and entity2.construction.connected then
        --    engine.messaging:emit("disconnect", entity1, entity2)
        --end
        --return true
    end)

    engine.messaging:register("connect", function(entity1, entity2)
        print("Connect")
        construction:connect(entity1, entity2)
    end)

    engine.messaging:register("disconnect", function(entity1, entity2)
        entity1.construction.connected = false
        entity2.construction.connected = false
    end)
end

function Construction:init_entity(entity, object)
    entity.construction = {
        connected = false 
    }
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
    assert(o1.construction and o2.construction,
           "Connect: wrong argument types (construction expected)")

    print(o1.transform, o2.transform)

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

    o1.construction.connected = true
    o2.construction.connected = true

    print("Connecting...")

    o2BaseAncestor.entity.physics.body:setPosition(o2BaseAncestor.entity.transform:getAbsolutePosition():unpack())
    o2BaseAncestor.entity.physics.body:setAngle(o2BaseAncestor.entity.transform:getAbsoluteRotation())

    local o1BaseAncestor = o1.transform:getBaseAncestor()
    --o1BaseAncestor.entity.transform:setParent(locator.transform)

    self.engine.systems['physics']:disable_physics(o1BaseAncestor.entity)
    self.engine.systems['physics']:disable_physics(o2BaseAncestor.entity)

    return locator
end

return Construction
