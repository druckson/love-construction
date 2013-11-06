local vector = require "lib/hump/vector"

return {
    circle = function(data, matrix)
        local x, y = matrix:getPosition():unpack()
        return love.physics.newCircleShape(x, y, data.radius)
    end,
    square = function(data, matrix)
        local l = data.sideLength
        local coords = {}

        x, y = (matrix * vector.new( l/2, l/2)):unpack()
        table.insert(coords, x)
        table.insert(coords, y)
        x, y = (matrix * vector.new( l/2, -l/2)):unpack()
        table.insert(coords, x)
        table.insert(coords, y)
        x, y = (matrix * vector.new(-l/2, -l/2)):unpack()
        table.insert(coords, x)
        table.insert(coords, y)
        x, y = (matrix * vector.new(-l/2,  l/2)):unpack()
        table.insert(coords, x)
        table.insert(coords, y)

        return love.physics.newPolygonShape(unpack(coords))
    end,
    rectangle = function(data, matrix)
        local w = data.width
        local h = data.height
        local coords = {}

        local x, y

        x, y = (matrix * vector.new(w/2, h/2)):unpack()
        table.insert(coords, x)
        table.insert(coords, y)
        x, y = (matrix * vector.new(w/2, -h/2)):unpack()
        table.insert(coords, x)
        table.insert(coords, y)
        x, y = (matrix * vector.new(-w/2, -h/2)):unpack()
        table.insert(coords, x)
        table.insert(coords, y)
        x, y = (matrix * vector.new(-w/2, h/2)):unpack()
        table.insert(coords, x)
        table.insert(coords, y)

        return love.physics.newPolygonShape(unpack(coords))
    end,
    triangle = function(data, matrix)
        local angle = 0
        local point = vector.new(data.radius, 0)
        local coords = {}

        for i = 0, 2 do
            local x, y = (matrix * point:rotated(i*2*math.pi/3)):unpack()
            table.insert(coords, x)
            table.insert(coords, y)
        end

        return love.physics.newPolygonShape(unpack(coords))
    end
}
