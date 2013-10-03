local vector = require "lib/hump/vector"
local transform = require "utils/transform"

local Entity = {
    objects = {}
}
Entity.__index = Entity

function Entity.new(parent)
    local newEntity = {
        transform = transform(),
        children = {},
        parent = nil
    }

    if parent ~= nil then
        assert(getmetatable(parent) == Entity)
        parent:addChild(newEntity)
    end

    return setmetatable(newEntity, Entity)
end

function Entity:addChild(child)
    if child.parent ~= nil then
        table.remove(child.parent.children, child)
    end
    child.parent = self
    table.insert(self.children, child)
end

return setmetatable({new = Entity.new}, {Entity.new})
