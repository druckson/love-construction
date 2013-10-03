local vector = require "lib/hump/vector"
local transform = require "utils/transform"

local Object = {
    objects = {}
}
Object.__index = Object

function Object.new(parent)
    local newObject = {
        transform = transform(),
        children = {},
        parent = nil
    }

    if parent ~= nil then
        assert(getmetatable(parent) == Object)
        parent:addChild(newObject)
    end

    return setmetatable(newObject, Object)
end

function Object:addChild(child)
    if child.parent ~= nil then
        table.remove(child.parent.children, child)
    end
    child.parent = self
    table.insert(self.children, child)
end

return setmetatable({new = Object.new}, {Object.new})
