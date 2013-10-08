local vector = require "lib/hump/vector"
local transform = require "utils/transform"

local Entity = {
    objects = {}
}
Entity.__index = Entity

function Entity.new(parent)
    local parentTransform = nil

    if (parent ~= nil) then
        parentTransform = parent.transform
    end

    local newEntity = {
        transform = transform(self, parentTransform)
    }
    return setmetatable(newEntity, Entity)
end

return setmetatable({new = Entity.new}, {Entity.new})
