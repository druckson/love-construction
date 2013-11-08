local transform = require "utils/transform"
local vector = require "lib/hump/vector"
local Matrix = require "utils/matrix"
local entity = require "entity"
local interpolaters = require "utils/interpolaters"
local Class = require "lib/hump/class"
local shapes = require "utils/shapes"

local Physics = Class{
    init = function(self, integrator)
        local physics = self

        self.integrator = integrator
        self.world = love.physics.newWorld(0, 0, true)
        --self.world:setGravity(0, -9.8)
        love.physics.setMeter(1)

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

        self.gravity = function(_, state, entity)
            local position = state.x
            local velocity = state.y
            local acceleration = vector.new(0, 0)
            
            for _, gravityObject in pairs(physics.gravityObjects) do
                if gravityObject ~= entity then
                    local gravityVector = (gravityObject.transform.position - position)
                    local gravityDist2 = gravityVector:len2()
                    local mass = gravityObject.physics.body:getMass()
                    acceleration = acceleration + (gravityVector:normalized() * (mass / gravityDist2))
            
                    -- Add atmosphere
                    --local radius = gravityObject.physics.gravity.atmosphere.radius
                    --local radius2 = radius * radius
                    --local atmosphereRadius = gravityObject.physics.gravity.atmosphere.level
                    --local atmosphereRadius2 = atmosphereRadius * atmosphereRadius
            
                    --local drag = invlerp(atmosphereRadius2, radius2, gravityDist2) * gravityObject.physics.gravity.atmosphere.density
            
                    --local localVelocity = velocity - vector.new(gravityObject.physics.body:getLinearVelocity())
            
                    --if gravityDist2 < atmosphereRadius2 then
                    --    acceleration = acceleration - (localVelocity * drag)
                    --end
                end
            end
            
            return vector.new(velocity, acceleration)
        end
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

function Physics:createShape(data, m)
    if shapes[data.type] then
        return shapes[data.type](data, m)
    end
    return nil
end

function Physics:init_entity(entity, data)
    entity.physics = {
        data = data.physics
    }

    self:enable_physics(entity)
end

function Physics:enable_physics(entity, recurse)
    local groupIndex
    local body

    if entity.transform.parent then
        body = entity.transform:getBaseAncestor().entity.physics.body
        groupIndex = entity.transform:getBaseAncestor().entity.physics.data.groupIndex
    else
        body = love.physics.newBody(self.world,
                                    entity.transform.position.x,
                                    entity.transform.position.y,
                                    entity.physics.data.bodyType)
        body:setBullet(true)
        entity.physics.body = body
        body:setAngle(-entity.transform:getAbsoluteRotation())

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

    if entity.physics.data.shape then
        if not (entity.construction and 
            entity.construction.type == "socket" and 
            entity.construction.connected) then

            local m = Matrix.new()
            if entity.transform.parent then
                m = entity.transform:getLocalMatrix()
            end
            local shape = self:createShape(entity.physics.data.shape, m)

            local  fixture = love.physics.newFixture(body, shape,
                                  entity.physics.data.density or 1)
            fixture:setUserData(entity)

            if groupIndex then
                fixture:setGroupIndex(groupIndex)
            end

            if entity.construction and
                entity.construction.type == "socket" then
                fixture:setSensor(true)
            end

            entity.physics.fixture = fixture
        end
    end

    if recurse then
        for _, child in pairs(entity.transform.children) do
            self:enable_physics(child.entity, recurse)
        end
    end
end

function Physics:disable_physics(entity)
    if entity.physics then
        if entity.physics.fixture then
            entity.physics.fixture:destroy()
            entity.physics.fixture = nil
        end

        if entity.physics.body then
            entity.physics.body:destroy()
            entity.physics.body = nil
        end
    end
end

function Physics:remove_entity(entity)
    for key, value in pairs(self.entities) do
        if value == entity then
            self:disable_physics(entity)
            entity.physics = nil
            entity.test = "Hello"
            table.remove(self.entities, key)
            self.entities[key] = nil
        end
    end
end

function Physics:matchTransform(entity)
    entity.physics.body:setPosition(entity.transform:getAbsolutePosition():unpack())
    entity.physics.body:setAngle(entity.transform:getAbsoluteRotation())
end

function Physics:update(dt)
    local physics = self
    local bodyCount = 0
    for _, entity in pairs(self.entities) do
        if entity.transform.parent == nil then
            bodyCount = bodyCount + 1
            if #physics.gravityObjects > 0 then
                local position = entity.transform.position
                local velocity = vector.new(entity.physics.body:getLinearVelocity())
                local state = vector.new(position, velocity)
                _, state = self.integrator(0, dt, state, self.gravity, entity)
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
