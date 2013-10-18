local transform = require "utils/transform"
local vector = require "lib/hump/vector"
local entity = require "entity"
local interpolaters = require "utils/interpolaters"
local Class = require "lib/hump/class"

local Physics = Class{
    init = function(self, integrator)
        local physics = self

        self.integrator = integrator
        self.world = love.physics.newWorld(0, 0, true)

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
    local physics = self
    engine.registry:register("init_entity", function(...)
        physics:init_entity(...)
    end)
    engine.registry:register("remove_entity", function(...)
        physics:remove_entity(...)
    end)
end

function Physics:beginContact(a, b, collision)

end

function Physics:endContact(a, b, collision)

end

function Physics:preSolve(a, b, collision)

end

function Physics:postSolve(a, b, collision)

end

local function CreateShape(data)
    local shape
    if data.type == "circle" then
        return love.physics.newCircleShape(data.radius)
    elseif data.type == "square" then
        return love.physics.newRectangleShape(data.sideLength, data.sideLength)
    end
    return nil
end

function Physics:init_entity(entity, object)
    local body = love.physics.newBody(self.world,
                                    entity.transform.position.x, 
                                    entity.transform.position.y,
                                    object.physics.bodyType)
    local  fixture = love.physics.newFixture(body, CreateShape(object.physics.shape), object.physics.density or 1)

    body:setAngle(-entity.transform.rotation)

    entity.physics = {body = body, fixture = fixture}

    table.insert(self.entities, entity)
end

function Physics:remove_entity(entity)
    for key, value in self.entities do
        if value == entity then
            entity.physics.body:destroy()
            entity.physics.fixture:destroy()
            table.remove(entity, "physics")
            table.remove(self.entities, key)
        end
    end
end

function Physics:addCustomConstraint(constraint)

end

function Physics:addGravityObject(object, radius, atmosphereRadius, atmosphereDensity) 
    table.insert(self.gravityObjects, {
        object = object,
        radius = radius,
        atmosphere = {
            radius = atmosphereRadius,
            density = atmosphereDensity or 0.01
        }
    })
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
                        if entity ~= gravityObject.entity then
                            local gravityVector = 
                                (gravityObject.entity.transform.position - position)
                            local gravityDist2 = gravityVector:len2()
                            local mass = gravityObject.entity.physics.body:getMass()
                            acceleration = acceleration + (gravityVector * (mass / gravityDist2))

                            local radius = gravityObject.radius
                            local radius2 = radius * radius
                            local atmosphereRadius = gravityObject.atmosphere.radius
                            local atmosphereRadius2 = atmosphereRadius * atmosphereRadius

                            local drag = invlerp(atmosphereRadius2, radius2, gravityDist2) * gravityObject.atmosphere.density

                            local localVelocity = velocity - vector.new(gravityObject.entity.physics.body:getLinearVelocity())

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
        end
    end
end

return Physics
