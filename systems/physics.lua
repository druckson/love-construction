local transform = require"../utils/transform" local vector = require "lib/hump/vector"
local entity = require "entity"
local Class = require "lib/hump/class"

local Physics = Class{
    init = function(self)
        self.world = love.physics.newWorld(0, 0, true)
        self.objects = {}
    end
}

function Physics:add(object, shape, bodyType)
    local body = love.physics.newBody(self.world, 
                                      object.transform.position.x, 
                                      object.transform.position.y,
                                      bodyType)
    body:setAngle(-object.transform.rotation)
    local fixture = love.physics.newFixture(body, shape, 1)
    object.physics = {
        body = body,
        fixture = fixture
    }

    table.insert(self.objects, object)
end

function Physics:addGravity(x, y, strength) 
    self.strength = strength
    self.center = vector.new(x, y)
end

function Physics:remove(object)
    for key, value in self.objects do
        if value == object then
            table.remove(self.objects, key)
        end
    end
end

function Physics:update(dt)
    self.world:update(dt)
    for _, object in pairs(self.objects) do
        if object.transform.parent == nil then
            if self.center and self.strength then
                local gravityVector = (self.center - object.transform.position)
                gravityVector = gravityVector * (self.strength / gravityVector:len2())
                object.physics.body:applyForce(gravityVector:unpack())
            end

            object.transform.position = vector.new(object.physics.body:getPosition())
            object.transform.rotation = object.physics.body:getAngle()
        end
    end
end

return Physics
