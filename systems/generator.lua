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
        charge = 1000
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
        if math.random() > 0.95 then
            entity.electricity.outputCharge = 1
        else
            entity.electricity.outputCharge = 0
        end
    end
end

return Generator
