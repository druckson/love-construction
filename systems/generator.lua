local Class = require "lib/hump/class"

local Generator = Class{
    init = function(self)
        self.entities = {}
    end
}

function Generator:setup(engine)
    self.engine = engine
end

function Generator:init_entity(entity, data)
    entity.generator = {
        burnSpeed = data.generator.burnSpeed,
        fuel = data.generator.fuel
    }
    table.insert(self.entities, entity)
end

function Generator:remove_entity(entity)
    entity.generator = nil
    for key, value in self.entities do
        if value == entity then
            table.remove(self.entities, key)
        end
    end
end

function Generator:update(dt)
    for _, entity in pairs(self.entities) do
        --local parent = entity.transform:getBaseAncestor()
        --local x, y = parent.entity.physics.body:getLinearVelocity()
        --local power = math.abs(x) + math.abs(y)
        --entity.electricity.outputCharge = entity.electricity.outputCharge + (0.1 * power * dt)

        local burn = math.min(entity.generator.burnSpeed*dt, entity.generator.fuel)
        entity.generator.fuel = entity.generator.fuel - burn
        entity.electricity.outputCharge = entity.electricity.outputCharge + burn
    end
end

return Generator
