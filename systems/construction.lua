local transform = require "../utils/transform"
local vector = require "lib/hump/vector"
local entity = require "entity"
local Class = require "lib/hump/class"
local shapes = require "utils/shapes"

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

        if  entity1.construction and 
            entity2.construction and
            not entity1.construction.connected and 
            not entity2.construction.connected then
            engine.messaging:emit("connect", entity1, entity2)
        end
        return true
    end)

    engine.messaging:register("connect", function(entity1, entity2)
        construction:connect(entity1, entity2)
    end)

    engine.messaging:register("disconnect", function(entity1, entity2)
        entity1.construction.connected = false
        entity2.construction.connected = false
    end)
end

function Construction:init_entity(entity, data)
    entity.construction = {
        type = data.construction.type,
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

-- Move two join points to the same position by moving their parents
function Construction:positionObjects(joint1, object1,
                                      joint2, object2)
    local locator1 = self.engine:createEntity({
        transform = {
            position = {0, 0},
            rotation = 0
        }
    })

    locator1.transform:setMatrix(joint1.transform:getAbsoluteMatrix())
    object1.transform:setParent(locator1.transform)
    
    -- Move the join point (locator) to the second object
    locator1.transform:setMatrix(joint2.transform:getAbsoluteMatrix())
    
    -- Line it up
    locator1.transform:rotate(math.pi)
    
    -- Remove the temporary locator
    object1.transform:removeParent()

    self.engine:removeEntity(locator1)
end

function Construction:getObjects(object)
    if object.construction and
       object.construction.type == "composite" then
       print("Composite")
       print(object)

       local objects = {}
       for _, objTransform in pairs(object.transform.children) do
            objTransform:removeParent()
            table.insert(objects, objTransform.entity)
       end
       print(#object.transform.children)
       print(#objects)

       return objects
    end

    return {object}
end

function Construction:getAllObjects(o1, o2)
    local objects = {}
    
    for _, object in pairs(self:getObjects(o1)) do
        table.insert(objects, object)
    end
    
    for _, object in pairs(self:getObjects(o2)) do
        table.insert(objects, object)
    end
    print(#objects)

    return objects
end

function Construction:computeCenterOfMass(objects)
    local totalMass = 0
    local centerOfMass = vector(0, 0)

    for _, o in pairs(objects) do
        local data = o.physics.data
        if data.shape and shapes[data.shape.type] then
            local shape = shapes[data.shape.type](0, 0, data.shape)
            local x, y, mass = shape:computeMass(data.density)
            local pos = vector.new(o.transform.position.x + x, o.transform.position.y + y)

            -- Moving average
            local newTotalMass = totalMass + mass
            centerOfMass = (centerOfMass * totalMass/newTotalMass) + (pos * mass/newTotalMass)
            totalMass = newTotalMass
        end
    end
    return centerOfMass
end

function Construction:joinObjects(objects)
    local centerOfMass = self:computeCenterOfMass(objects)

    for _, o in pairs(objects) do
        self.engine.systems['physics']:disable_physics(o)
    end

    local parent = self.engine:createEntity({
        transform = {
            position = {centerOfMass.x, centerOfMass.y},
            rotation = 0
        },
        physics = {
            bodyType = "dynamic"
        },
        display = {
            dummy = true
        },
        construction = {
            type = "composite"
        }
    })

    for _, o in pairs(objects) do
        o.transform:setParent(parent.transform)
    end
    print("New parent")
    print(parent)
    print(#parent.transform.children)

    self.engine.systems['physics']:enable_physics(parent, true)
    print(#parent.transform.children)

    --for _, o in pairs(objects) do
    --    self.engine.systems['physics']:enable_physics(o)
    --end
end

function Construction:connect(o1, o2)
    assert(o1.construction and o2.construction,
           "Connect: wrong argument types (construction expected)")

    -- Transform the first object in relation to the join point
    local o2BaseAncestor = o2.transform:getBaseAncestor().entity
    local o1BaseAncestor = o1.transform:getBaseAncestor().entity

    if  o1BaseAncestor ~= o2BaseAncestor and
        not o1.construction.connected and 
        not o2.construction.connected then

        if o1BaseAncestor.physics.body:getMass() > o2BaseAncestor.physics.body:getMass() then
            self:positionObjects(o2, o2BaseAncestor, o1, o1BaseAncestor)
        else
            self:positionObjects(o1, o1BaseAncestor, o2, o2BaseAncestor)
        end


        self:joinObjects(self:getAllObjects(o1BaseAncestor, o2BaseAncestor))

        o1.construction.connected = true
        o2.construction.connected = true

        --if o2BaseAncestor.entity.physics then
        --    o2BaseAncestor.entity.physics.body:setPosition(o2BaseAncestor.entity.transform:getAbsolutePosition():unpack())
        --    o2BaseAncestor.entity.physics.body:setAngle(o2BaseAncestor.entity.transform:getAbsoluteRotation())
        --end

        --o1BaseAncestor.entity.transform:setParent(locator.transform)

        --love.physics.newWeldJoint(o1BaseAncestor.physics.body,
        --                          o2BaseAncestor.physics.body,
        --                          locator.transform.position.x,
        --                          locator.transform.position.y,
        --                          false)

        --self.engine.systems['physics']:disable_physics(o1BaseAncestor)
        --self.engine.systems['physics']:disable_physics(o2BaseAncestor)
    end
end

return Construction
