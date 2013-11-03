local transform = require "utils/transform"
local vector = require "lib/hump/vector"
local entity = require "entity"
local interpolaters = require "utils/interpolaters"
local Class = require "lib/hump/class"
local shapes = require "utils/shapes"

local Physics = Class{
    init = function(self, integrator)
        local physics = self

        self.integrator = integrator
        self.world = love.physics.newWorld(0, 0, true)
        --love.physics.setMeter(1)

        self.world:setCallbacks(function(...)
            self:beginContact(...)
        end, function(...)
            self:endContact(...)
        end, function(...)
            self:preSolve(...)
        end, function(...)
            self:postSolve(...)
        end)

        self.entities = {}
        self.gravityObjects = {}
    end
}

function Physics:setup(engine)
    self.engine = engine
    local physics = self
    engine.messaging:register("init_entity", function(...)
        physics:init_entity(...)
    end)
    engine.messaging:register("remove_entity", function(...)
        physics:remove_entity(...)
    end)
end

function Physics:beginContact(a, b, collision)
    self.engine.messaging:emit("begin_contact", a, b, collision)
end

function Physics:endContact(a, b, collision)
    self.engine.messaging:emit("end_contact", a, b, collision)
end

function Physics:preSolve(a, b, collision)

end

function Physics:postSolve(a, b, collision)

end

local function CreateShape(data)
    local shape
    --if data.type == "circle" then
    --    return love.physics.newCircleShape(data.radius)
    --elseif data.type == "square" then
    --    return love.physics.newRectangleShape(data.sideLength/2, data.sideLength/2)
    --end
    
    if shapes[data.type] then
        print(shapes[data.type](data, 0, 0))
        return shapes[data.type](data, 0, 0)
    end
    return nil
end

function Physics:init_entity(entity, data)
    entity.physics = {
        data = data.physics
    }
    self:enable_physics(entity)
end

function Physics:enable_physics(entity)
    local position = entity.transform:getAbsolutePosition()
    local body = love.physics.newBody(self.world,
                                    position.x,
                                    position.y,
                                    entity.physics.data.bodyType)
    local  fixture = love.physics.newFixture(body, 
                                             CreateShape(entity.physics.data.shape), 
                                             entity.physics.data.density or 1)
    fixture:setUserData(entity)

    body:setAngle(-entity.transform:getAbsoluteRotation())

    entity.physics.body = body
    entity.physics.fixture = fixture

    if entity.physics.data.velocity then
        body:setLinearVelocity(entity.physics.data.velocity[1], 
                               entity.physics.data.velocity[2])
    end

    if entity.physics.data.gravity then
        entity.physics.gravity = entity.physics.data.gravity
        table.insert(self.gravityObjects, entity)
    end

    table.insert(self.entities, entity)
end

function Physics:disable_physics(entity)
    entity.physics.fixture:destroy()
    entity.physics.fixture = nil

    entity.physics.body:destroy()
    entity.physics.body = nil

    for key, value in pairs(self.entities) do
        if value == entity then
            table.remove(self.entities, key)
        end
    end
end

function Physics:remove_entity(entity)
    for key, value in pairs(self.entities) do
        if value == entity then
            entity.physics.fixture:destroy()
            entity.physics.body:destroy()
            --entity.physics = nil
            table.remove(self.entities, key)
        end
    end
end

function Physics:update(dt)
    local physics = self
    for _, entity in pairs(self.entities) do
        if entity.transform.parent == nil then
            if #physics.gravityObjects > 0 then
                local position = entity.transform.position
                local velocity = vector.new(entity.physics.body:getLinearVelocity())
                local state = vector.new(position, velocity)
                _, state = self.integrator(0, dt, state, function(_, state)
                    local position = state.x
                    local velocity = state.y
                    local acceleration = vector.new(0, 0)

                    for _, gravityObject in pairs(physics.gravityObjects) do
                        if entity ~= gravityObject then
                            local gravityVector = 
                                (gravityObject.transform.position - position)
                            local gravityDist2 = gravityVector:len2()
                            local mass = gravityObject.physics.body:getMass()
                            acceleration = acceleration + (gravityVector * (mass / gravityDist2))

                            local radius = gravityObject.physics.gravity.atmosphere.radius
                            local radius2 = radius * radius
                            local atmosphereRadius = gravityObject.physics.gravity.atmosphere.level
                            local atmosphereRadius2 = atmosphereRadius * atmosphereRadius

                            local drag = invlerp(atmosphereRadius2, radius2, gravityDist2) * gravityObject.physics.gravity.atmosphere.density

                            local localVelocity = velocity - vector.new(gravityObject.physics.body:getLinearVelocity())

                            if gravityDist2 < atmosphereRadius2 then
                                acceleration = acceleration - (localVelocity * drag)
                            end
                        end
                    end

                    return vector.new(velocity, acceleration)
                end)
                entity.physics.body:setLinearVelocity(state.y:unpack())
            end
        end
    end

    self.world:update(dt)

    for _, entity in pairs(self.entities) do
        if entity.transform.parent == nil then
            entity.transform.position = vector.new(entity.physics.body:getPosition())
            entity.transform.rotation = entity.physics.body:getAngle()
        else
            entity.physics.body:setPosition(entity.transform:getAbsolutePosition():unpack())
            entity.physics.body:setAngle(entity.transform:getAbsoluteRotation())
        end
    end
end

return Physics
