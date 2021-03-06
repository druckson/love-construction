local Class = require "lib/hump/class"
local Registry = require "lib/hump/signal"
local Transform = require "utils/transform"
local Messaging = require "utils/messaging"

local Engine = Class{
    init = function(self)
        self.messaging = Messaging()
        self.systems = {}
        self.systems_ordered = {}
        self.entities = {}
    end
}

function Engine:addSystem(name, system)
    self.systems[name] = system
    table.insert(self.systems_ordered, system)
    system:setup(self)

    return self
end

function Engine:createEntity(data)
    local entity = {}

    entity.transform = Transform(entity)
    if data.transform.parent then
        entity.transform:setParent(data.transform.parent)
    end
    entity.transform:setPosition(data.transform.position[1], data.transform.position[2])
    entity.transform:setRotation(data.transform.rotation)

    for key, value in pairs(data) do
        if self.systems[key] ~= nil then
            self.systems[key]:init_entity(entity, data)
        end
    end

    table.insert(self.entities, entity)

    return setmetatable(entity, {
        __tostring = function(entity)
            local str = "Entity: "
            for name, system in pairs(entity) do
                if system.__tostring then
                    str = str .. "\n\t" .. name .. ": " .. system:__tostring()
                end
            end
            return str
        end
    })
end

function Engine:removeEntity(entity)
    for key, value in pairs(self.entities) do
        if value == entity then
            table.remove(self.entities, key)

            -- Remove the entity from any systems it's registered with
            for key, value in pairs(entity) do
                if self.systems[key] ~= nil then
                    self.systems[key]:remove_entity(entity)
                end
            end
        end
    end

    return self
end

function Engine:update(...)
    for _, system in pairs(self.systems_ordered) do
        if system.update then
            system:update(...)
        end
    end
end

function Engine:display(...)
    for _, system in pairs(self.systems) do
        if system.display then
            system:display(...)
        end
    end
end

return Engine
