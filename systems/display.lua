local vector = require "lib/hump/vector"
local vector3 = require "utils/vector3"
local Class = require "lib/hump/class"
local color = require "utils/color"
require "leaf"

local function getColor(data)
    if data.space == "hsva" then
        return color.HsvToRgb(data.h, data.s, data.v, data.a)
    elseif data.space == "rgba" then
        return {data.r, data.g, data.b, data.a}
    end
end

local ShapeDisplay = Class{
    init = function(self, assets, entity, data)
        self.assets = assets
        self.entity = entity
        if data then
            for key, value in pairs(data) do
                self[key] = value
            end
            if data.color then
                self:setColor(data.color)
            end
        else
            self.dummy = true
        end
    end
}

function ShapeDisplay:setColor(data)
    self.color = getColor(data)
end

function ShapeDisplay:display()
    love.graphics.push()
    love.graphics.translate(self.entity.transform:getAbsolutePosition():unpack())
    love.graphics.rotate(self.entity.transform:getAbsoluteRotation())

    if not self.dummy then 
        if self.type == "rectangle" then
            local width  = self.width
            local height = self.height
            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill", -width/2, -height/2, width, height)
        elseif self.type == "square" then
            local sideLength = self.sideLength
            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill", -sideLength/2, -sideLength/2, sideLength, sideLength)
        elseif self.type == "circle" then
            love.graphics.setColor(self.color)
            love.graphics.circle("fill", 0, 0, self.radius)
        elseif self.type == "triangle" then
            local angle = 0
            local point = vector.new(self.radius, 0)
            local coords = {}

            for i = 0, 2 do
                table.insert(coords, point:rotated(i*2*math.pi/3).x)
                table.insert(coords, point:rotated(i*2*math.pi/3).y)
            end
            love.graphics.setColor(self.color)
            love.graphics.polygon("fill", coords)
        elseif self.type == "image" then
            local width  = self.width
            local height = self.height
            local image = self.assets.images[self.image]
            local iwidth = image:getWidth()
            local iheight = image:getHeight()

            if self.shader then
                local shader = self.assets.shaders[self.shader]
                local lightDirection = (self.entity.transform:getChangeOfBasis() * vector.new(0, 0))
                local lightNormal = vector3(lightDirection.x, lightDirection.y, 1)
                shader:send("lightNormal", {lightNormal:normalized():unpack()})
                love.graphics.setPixelEffect(shader)
            end

            love.graphics.draw(image, 
                               -width/2, -height/2, 0, 
                               width/iwidth, height/iheight)
            love.graphics.setPixelEffect()
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
        self.fuel = ""
        self.battery = ""
        self.assets = {}
        self.assets.shaders = leaf.fs.loadShaders("assets/shaders", function(progress, path)
            print("Loading shader: ", path) 
        end)
        self.assets.images = leaf.fs.loadImages("assets/images", function(progress, path)
            print("Loading image: ", path) 
        end)
    end
}

function Display:setup(engine)
    self.engine = engine
end

function Display:init_entity(entity, data)
    --if data and data.display then
    --    for _, displayData in pairs(data.display) do
    --        if displayData.type == "shape" then
    --            
    --        elseif displayData.type == "shape" then

    --        end
    --    end
    --end

    if data and 
        data.display[1] and
        not data.display[1].dummy then
        
        entity.display = ShapeDisplay(self.assets, entity, data.display[1])
    else
        entity.display = ShapeDisplay(self.assets, entity)
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

function Display:setFuel(message)
    self.fuel = message
end

function Display:setBattery(message)
    self.battery = message
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
        entity.display:display()
    end
    love.graphics.pop()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
    love.graphics.print("Speed: "..self.speedometer, 10, 20)
    love.graphics.print("Fuel: "..self.fuel, 10, 30)
    love.graphics.print("Battery: "..self.battery, 10, 40)
end

return Display
