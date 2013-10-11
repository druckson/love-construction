local transform = require"../utils/transform" local vector = require "lib/hump/vector"
local entity = require "entity"

local Physics = {
    world = love.physics.newWorld(-1, -1, true),
    objects = {}
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
        object.transform.position = vector.new(object.physics.body:getPosition())
        object.transform.rotation = object.physics.body:getAngle()
    end
end

return Physics
