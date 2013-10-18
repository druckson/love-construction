local Class = require "lib/hump/class"
local Registry = require "lib/hump/signal"
local Transform = require "utils/transform"

local Engine = Class{
    init = function(self)
        self.registry = Registry()
        self.systems = {}
        self.entities = {}
    end
}

function Engine:addSystem(name, system)
    self.systems[name] = system
    system:setup(self)

    return self
end

function Engine:addEntity(data)
    local entity = {
         transform = Transform(entity)
    }
    --print(data.transform.rotation)
    entity.transform:setPosition(data.transform.position[0], data.transform.position[1])
    entity.transform:setRotation(data.transform.rotation)

    for key, value in pairs(data) do
        if self.systems[key] ~= nil then
            self.systems[key]:init_entity(entity, data)
            --self.registry:emit("init_entity", entity, data)
        end
    end

    table.insert(self.entities, entity)

    return self
end

function Engine:removeEntity(entity)
    for key, value in pairs(self.entities) do
        if value == entity then
            table.remove(self.entities, key)
            self.registry:emit("remove_entity", entity)
        end
    end

    return self
end

return Engine
