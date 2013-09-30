local vector = require "../hump/vector"

local Display = {
    screenSize = vector.new(300, 300),
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

    if object.display ~= nil then
        love.graphics.setColor(object.display.color)

        local properties = object.display.properties
        if object.display.shape == "rect" then
            love.graphics.rectangle("fill", -properties.size.x/2, -properties.size.y/2,
                                    properties.size.x, 
                                    properties.size.y)
        elseif object.display.shape == "square" then
            love.graphics.rectangle("fill", -properties.size/2, -properties.size/2,
                                    properties.size, 
                                    properties.size)
        elseif object.display.shape == "circle" then
            love.graphics.circle("fill", -properties.radius/2, -properties.radius/2, properties.radius)
        elseif object.display.shape == "triangle" then
            local points = {}
            love.graphics.polygon("fill", {
                math.cos(0)*properties.radius, 
                math.sin(0)*properties.radius,
                math.cos(2*math.pi/3)*properties.radius, 
                math.sin(2*math.pi/3)*properties.radius,
                math.cos(4*math.pi/3)*properties.radius, 
                math.sin(4*math.pi/3)*properties.radius})
        end
    end

    for _, child in pairs(object.transform.children) do
        self:displayChildren(child)
    end

    love.graphics.pop()
end

function Display:setScreenSize(x, y)
    love.graphics.setMode(x, y, true, true, 3)
    love.mouse.setVisible(false)
    self.screenSize = vector.new(x, y)
end

function Display:moveCamera(x, y)
    self.camera.position = vector.new(x, y)
end

function Display:rotateCamera(r)
    self.camera.rotation = r
end

function Display:zoomCamera(z)
    self.camera.zoom = z
end

function Display:display()
    love.graphics.setBackgroundColor(255, 255, 255, 255)
    love.graphics.clear()

    local zoom = self.camera.zoom

    love.graphics.push()
    love.graphics.translate(self.screenSize.x/2, self.screenSize.y/2)
    love.graphics.rotate(-self.camera.rotation)
    love.graphics.scale(zoom, zoom)
    love.graphics.translate(-self.camera.position.x, -self.camera.position.y)

    for _, object in pairs(self.objects) do
        if object.transform.parent == nil then
            self:displayChildren(object)
        end
    end
    love.graphics.pop()

    love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
end

return Display
