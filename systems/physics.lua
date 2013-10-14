local transform = require"../utils/transform"
local vector = require "lib/hump/vector"
local entity = require "entity"
local interpolaters = require "utils/interpolaters"
local Class = require "lib/hump/class"

local Physics = Class{
    init = function(self, integrator)
        self.integrator = integrator
        self.world = love.physics.newWorld(0, 0, true)
        self.objects = {}
        self.gravityObjects = {}
    end
}

function Physics:add(object, shape, bodyType, mass)
    local body = love.physics.newBody(self.world, 
                                      object.transform.position.x, 
                                      object.transform.position.y,
                                      bodyType)
    body:setAngle(-object.transform.rotation)
    local fixture = love.physics.newFixture(body, shape, 1)
    object.physics = {
        body = body,
        fixture = fixture,
        mass = mass
    }

    table.insert(self.objects, object)
end

function Physics:addCustomConstraint(constraint)

end

function Physics:addGravityObject(object, radius, atmosphereRadius, atmosphereDensity) 
    table.insert(self.gravityObjects, {
        object = object,
        radius = radius,
        atmosphere = {
            radius = atmosphereRadius,
            density = atmosphereDensity
        }
    })
end

function Physics:remove(object)
    for key, value in self.objects do
        if value == object then
            table.remove(self.objects, key)
        end
    end
end

function Physics:update(dt)
    local physics = self
    for _, object in pairs(self.objects) do
        if object.transform.parent == nil then
            if #physics.gravityObjects > 0 then
                local position = object.transform.position
                local velocity = vector.new(object.physics.body:getLinearVelocity())
                local state = vector.new(position, velocity)
                _, state = self.integrator(0, dt, state, function(_, state)
                    local position = state.x
                    local velocity = state.y
                    local acceleration = vector.new(0, 0)

                    for _, gravityObject in pairs(physics.gravityObjects) do
                        if object ~= gravityObject.object then
                            local gravityVector = 
                                (gravityObject.object.transform.position - position)
                            local gravityDist2 = gravityVector:len2()
                            acceleration = acceleration + (gravityVector * (gravityObject.object.physics.mass / gravityDist2))

                            local radius = gravityObject.radius
                            local radius2 = radius * radius
                            local atmosphereRadius = gravityObject.atmosphere.radius
                            local atmosphereRadius2 = atmosphereRadius * atmosphereRadius

                            if gravityDist2 < atmosphereRadius2 then
                                acceleration = acceleration - (velocity * invlerp(atmosphereRadius2, radius2, gravityDist2) * 0.2)
                            end
                        end
                    end

                    return vector.new(velocity, acceleration)
                end)
                object.physics.body:setLinearVelocity(state.y:unpack())
            end
        end
    end

    self.world:update(dt)

    for _, object in pairs(self.objects) do
        if object.transform.parent == nil then
            object.transform.position = vector.new(object.physics.body:getPosition())
            object.transform.rotation = object.physics.body:getAngle()
        end
    end
end

return Physics
