local vector = require "lib/hump/vector"
local transform = require "utils/transform"

local Object = {
    objects = {}
}

function Object.new(parent)
    local newObject = {
        transform = transform(),
        children = {},
        parent = nil
    }

    if parent ~= nil then
        parent:addChild(newObject)
    end

    return newObject
end

function Transform:addChild(child)
    if child.parent ~= nil then
        table.remove(child.parent.children, child)
    end
    child.parent = self
    table.insert(self.children, child)
end

return setmetatable({new = Object.new}, {Object.new})
