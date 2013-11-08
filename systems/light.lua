local Class = require "lib/hump/class"

local Light = Class{
    init = function(self)
        self.entities = {}
    end
}

function Light:setup(engine)
    self.engine = engine
end

function Light:init_entity(entity, data)
    entity.light = {
        fullCharge = data.light.fullCharge,
        color = data.light.color
    }
    table.insert(self.entities, entity)
end

function Light:remove_entity(entity)
    entity.light = nil
    for key, value in self.entities do
        if value == entity then
            table.remove(self.entities, key)
        end
    end
end

function Light:update(dt)
    for _, entity in pairs(self.entities) do
        local draw = entity.electricity.draw
        local color = entity.light.color
        color.v = ((draw / entity.light.fullCharge))
        entity.display:setColor(color)
    end
end

return Light
