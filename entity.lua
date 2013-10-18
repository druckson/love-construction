local vector = require "lib/hump/vector"
local Transform = require "utils/transform"

local Entity = {
    objects = {}
}
Entity.__index = Entity

function Entity.new(parent)
    local parentTransform = nil

    if parent ~= nil then
        parentTransform = parent.transform
    end

    local newEntity = {}
    newEntity.transform = Transform(newEntity, parentTransform)
    return setmetatable(newEntity, Entity)
end

function Entity:__tostring()
    return "Entity: " .. self.transform:__tostring()
end

return setmetatable({new = Entity.new}, {Entity.new})
