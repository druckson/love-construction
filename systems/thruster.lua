local Class = require "lib/hump/class"

local Thruster = Class{
    init = function(self)
        self.entities = {}
    end
}

function Thruster:setup(engine)
    self.engine = engine
end

function Thruster:init_entity(entity, data)
    entity.thruster = {
        angle = data.thruster.angle,
        power = data.thruster.power
    }
    table.insert(self.entities, entity)
end

function Thruster:remove_entity(entity)
    entity.thruster = nil
    for key, value in self.entities do
        if value == entity then
            table.remove(self.entities, key)
        end
    end
end

function Thruster:update(dt)
    for _, entity in pairs(self.entities) do
        local body  = entity.transform:getBaseAncestor().entity.physics.body
        local x, y  = entity.transform:getLocalPosition():unpack()
        local angle = entity.transform:getLocalRotation()

        body:applyForce(x, y, 
            math.cos(angle+entity.thruster.angle) * entity.thruster.power, 
            math.sin(angle+entity.thruster.angle) * entity.thruster.power)
    end
end

return Thruster
