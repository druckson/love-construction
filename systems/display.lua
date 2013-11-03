local vector = require "lib/hump/vector"
local Class = require "lib/hump/class"
local color = require "utils/color"

local function getColor(data)
    if data.space == "hsva" then
        return color.HsvToRgb(data.h, data.s, data.v, data.a)
    elseif data.space == "rgba" then
        return {data.r, data.g, data.b, data.a}
    end
end

local Display = Class{
    init = function(self)
        self.screenSize = vector.new(300, 300)
        self.camera = {
            position = vector.new(0, 0),
            rotation = 0,
            zoom = 1
        }
        self.entities = {}
        self.speedometer = ""
    end
}

function Display:setup(engine)
    local display = self
    engine.messaging:register("init_entity", function(...)
        display:init_entity(...)
    end)
    engine.messaging:register("remove_entity", function(...)
        display:remove_entity(...)
    end)
end

function Display:init_entity(entity, data)
    if data then
        entity.display = {
            shape = data.display.shape,
            color = getColor(data.display.color),
        }
    end
    table.insert(self.entities, entity)
end

function Display:remove_entity(entity)
    for key, value in pairs(self.entities) do
        if value == entity then
            table.remove(self.entities, key)
        end
    end
end

function Display:displayChildren(entity)
    love.graphics.push()
    love.graphics.translate(entity.transform.position.x, entity.transform.position.y)
    love.graphics.rotate(entity.transform.rotation)

    if entity.display ~= nil then
        love.graphics.setColor(entity.display.color)

        local properties = entity.display.properties
        if entity.display.shape.type == "rect" then
            local width  = entity.display.shape.width
            local height = entity.display.shape.height
            love.graphics.rectangle("fill", -width/2, -height/2, width, height)
        elseif entity.display.shape.type == "square" then
            local sideLength = entity.display.shape.sideLength
            love.graphics.rectangle("fill", -sideLength/2, -sideLength/2, sideLength, sideLength)
        elseif entity.display.shape.type == "circle" then
            love.graphics.circle("fill", 0, 0, entity.display.shape.radius)
        elseif entity.display.shape.type == "triangle" then
            local radius = entity.display.shape.radius
            local points = {}
            love.graphics.polygon("fill", {
                math.cos(0)*radius, 
                math.sin(0)*radius,
                math.cos(2*math.pi/3)*radius, 
                math.sin(2*math.pi/3)*radius,
                math.cos(4*math.pi/3)*radius, 
                math.sin(4*math.pi/3)*radius})
        end
    end

    for _, child in pairs(entity.transform.children) do
        self:displayChildren(child.entity)
    end

    love.graphics.pop()
end

function Display:setSpeedometer(message)
    self.speedometer = message
end

function Display:setScreenSize(x, y)
    love.graphics.setMode(x, y, true, true, 3)
    self.screenSize = vector.new(x, y)
    --love.graphics.setMode(400, 400, false, true, 3)
    --self.screenSize = vector.new(400, 400)
    love.mouse.setVisible(false)
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
    love.graphics.setBackgroundColor(0, 0, 0, 255)
    love.graphics.clear()

    local zoom = 100 / self.camera.zoom

    love.graphics.push()
    love.graphics.translate(self.screenSize.x/2, self.screenSize.y/2)
    love.graphics.rotate(-self.camera.rotation)
    love.graphics.scale(zoom, zoom)
    love.graphics.translate(-self.camera.position.x, -self.camera.position.y)

    for _, entity in pairs(self.entities) do
        if not entity.transform.parent then
            self:displayChildren(entity)
        end
    end
    love.graphics.pop()

    love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
    love.graphics.print("Speed: "..self.speedometer, 10, 20)
end

return Display
