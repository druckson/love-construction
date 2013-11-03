local vector = require "lib/hump/vector"
local math = require "math"

function square(data, x, y)
    return love.physics.newPolygonShape(
        x - (data.sideLength/2),
        y - (data.sideLength/2),

        x - (data.sideLength/2),
        y + (data.sideLength/2),

        x + (data.sideLength/2),
        y + (data.sideLength/2),

        x + (data.sideLength/2),
        y - (data.sideLength/2)
    )
end

function circle(data, x, y)
    return love.physics.newCircleShape(x, y, data.radius)
end

return {
    square = square,
    circle = circle
}
