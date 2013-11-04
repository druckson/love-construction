local vector = require "lib/hump/vector"

return {
    circle = function(x, y, data)
        return love.physics.newCircleShape(x, y, data.radius)
    end,
    square = function(x, y, data)
        local l = data.sideLength
        return love.physics.newRectangleShape(x, y, l/2, l/2, 0)
    end,
    triangle = function(x, y, data)
        local angle = 0
        local point = vector.new(data.radius, 0)
        local coords = {}

        for i = 0, 2 do
            table.insert(coords, point:rotated(i*2*math.pi/3).x)
            table.insert(coords, point:rotated(i*2*math.pi/3).y)
        end

        return love.physics.newPolygonShape(unpack(coords))
    end
}
