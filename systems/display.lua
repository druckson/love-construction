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

local DisplayObject = Class{
    init = function(self, entity, data)
        self.entity = entity
        if data then
            self.shape = data.shape
            self:setColor(data.color)
        else
            self.dummy = true
        end
    end
}

function DisplayObject:setColor(data)
    self.color = getColor(data)
end

function DisplayObject:display()
    love.graphics.push()
    love.graphics.translate(self.entity.transform.position.x, self.entity.transform.position.y)
    love.graphics.rotate(self.entity.transform.rotation)

    if not self.dummy then 
        love.graphics.setColor(self.color)

        if self.shape.type == "rectangle" then
            local width  = self.shape.width
            local height = self.shape.height
            love.graphics.rectangle("fill", -width/2, -height/2, width, height)
        elseif self.shape.type == "square" then
            local sideLength = self.shape.sideLength
            love.graphics.rectangle("fill", -sideLength/2, -sideLength/2, sideLength, sideLength)
        elseif self.shape.type == "circle" then
            love.graphics.circle("fill", 0, 0, self.shape.radius)
        elseif self.shape.type == "triangle" then
            local angle = 0
            local point = vector.new(self.shape.radius, 0)
            local coords = {}

            for i = 0, 2 do
                table.insert(coords, point:rotated(i*2*math.pi/3).x)
                table.insert(coords, point:rotated(i*2*math.pi/3).y)
            end
            love.graphics.polygon("fill", coords)
        end
    end

    for _, child in pairs(self.entity.transform.children) do
        if child.entity.display then
            child.entity.display:display()
        end
    end

    love.graphics.pop()
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
    self.engine = engine
end

function Display:init_entity(entity, data)
    if data and 
        data.display and
        not data.display.dummy then
        entity.display = DisplayObject(entity, data.display)
    else
        entity.display = DisplayObject(entity)
    end
    table.insert(self.entities, entity)
end

function Display:remove_entity(entity)
    for key, value in pairs(self.entities) do
        if value == entity then
            entity.display = nil
            table.remove(self.entities, key)
        end
    end
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
            entity.display:display()
        end
    end
    love.graphics.pop()

    love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
    love.graphics.print("Speed: "..self.speedometer, 10, 20)
end

return Display
