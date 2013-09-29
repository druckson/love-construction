local vector = require "../hump/vector"

local Display = {
    camera = {
        position = vector.new(0, 0),
        rotation = 0,
        zoom = 1
    },
    objects = {}
}

function Display:add(object, shape, color, properties)
    object.display = {
        shape = shape,
        color = color,
        properties = properties
    }
    table.insert(self.objects, object)
end

function Display:displayChildren(object)
    love.graphics.push()
    love.graphics.translate(object.transform.position.x, object.transform.position.y)
    love.graphics.rotate(object.transform.rotation)

    love.graphics.setColor(object.display.color)

    local properties = object.display.properties
    if object.display.shape == "rect" then
        love.graphics.rectangle("fill", 0, 0,
                                properties.size.x, 
                                properties.size.y)
    elseif object.display.shape == "square" then
        love.graphics.rectangle("fill", 0, 0,
                                properties.size, 
                                properties.size)
    elseif object.display.shape == "circle" then
        love.graphics.circle("fill", 0, 0, properties.radius)
    end

    for _, child in pairs(object.transform.children) do
        self:displayChildren(child)
    end

    love.graphics.pop()
end

function Display:moveCamera(x, y)
    self.camera.position = self.camera.position + vector.new(x, y)
end

function Display:rotateCamera(r)
    self.camera.rotation = self.camera.rotation + r
end

function Display:zoomCamera(z)
    self.camera.zoom = self.camera.zoom + z
end

function Display:display()
    love.graphics.setBackgroundColor(255, 255, 255, 255)
    love.graphics.clear()
    love.graphics.push()

    love.graphics.translate(150, 150)
    love.graphics.rotate(self.camera.rotation)
    love.graphics.scale(self.camera.zoom, self.camera.zoom)
    love.graphics.translate(self.camera.position.x, self.camera.position.y)

    for _, object in pairs(self.objects) do
        if object.transform.parent == nil then
            self:displayChildren(object)
        end
    end
    love.graphics.pop()
end

return Display
