local vector = require "../../hump/vector"

local Matrix = {}

function Matrix.new()
    local newMatrix = {
        vector.new(1, 0),
        vector.new(0, 1),
        vector.new(0, 0)
    }

    return setmetatable(newMatrix, Matrix)
end

return setmetatable({}, {__call = Matrix.new})
