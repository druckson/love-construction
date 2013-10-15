local matrix = require "utils/matrix"
local color = require "utils/color"
local vector = require "lib/hump/vector"
local entity = require "entity"
local Class = require "lib/hump/class"

function iterateGR(start)
    local current = start
    return function()
        current = (current + 1.61803398875) % 1
        return current
    end
end

function radialToCartesian(radius, angle)
    return matrix.rotate(angle) * vector.new(0, radius)
end

local Scene = Class{
    init = function(self, display, physics, player)
        self.display = display
        self.physics = physics
        self.player =  player

        local gr = iterateGR(0)

        self.sun =      self:createGlobe(vector.new(0, 0),     color.HsvToRgb(gr(), 0.7, 0.7, 1.0), 500,  0, 1000)

        self.planet1 =  self:createGlobe(vector.new( 5000, 0), color.HsvToRgb(gr(), 0.7, 0.7, 1.0), 100, 20, 200, vector.new(0, -50))
        self.planet2 =  self:createGlobe(vector.new(-5000, 0), color.HsvToRgb(gr(), 0.7, 0.7, 1.0), 100, 20, 200, vector.new(0,  50))

        self.player1 = self:createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), vector.new(5150, 0), true, 1, vector.new(0, -45))
        --for i = 0, 50 do
        --    self:createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), 
        --        vector.new(2200, 0), true, 1, vector.new(0, -10))
        --end
    end
}

function Scene:createJoinPoint(parent, color, x, y, r)
    local childBlock = entity.new(parent)
    childBlock.transform:setPosition(x, y)
    childBlock.transform:setRotation(r)
    --display:add(childBlock, "triangle", color, {radius=0.1})
    construction:add(childBlock)
end

function Scene:createBlock(color, position, isPlayer, mass, velocity)
    local mainBlock = entity.new()
    mainBlock.transform:setPosition(position:unpack())

    mainBlock.transform:setRotation(
        math.random()*2*math.pi)
    
    self.display:add(mainBlock, "square", color, {size=1})
    self.physics:add(mainBlock, love.physics.newRectangleShape(0.5, 0.5), "dynamic", mass)
    if velocity then
        mainBlock.physics.body:setLinearVelocity(velocity:unpack())
    end


    if isPlayer then
        self.player:set(mainBlock, 1)
    else
        self.createJoinPoint(mainBlock, {60, 00, 00, 255}, 0.5,  0, 0)
        self.createJoinPoint(mainBlock, {60, 60, 60, 255}, 0,  0.5, math.pi/2)
        self.createJoinPoint(mainBlock, {60, 60, 60, 255}, -0.5, 0, math.pi)
        self.createJoinPoint(mainBlock, {60, 60, 60, 255}, 0, -0.5, -math.pi/2)
    end

    return mainBlock
end

function Scene:createGlobe(center, color, radius, atmosphere, mass, velocity)
    local globe = entity.new()
    globe.transform:setPosition(center:unpack())
    self.display:add(globe, "circle", color, {radius=radius})
    self.physics:add(globe, love.physics.newCircleShape(radius), "dynamic", mass)
    self.physics:addGravityObject(globe, radius, radius+atmosphere)

    if velocity then
        globe.physics.body:setLinearVelocity(velocity:unpack())
    end
    
    --local segments = 100
    --local translate = matrix.translate(center:unpack())
    --for i = 0, segments do
    --    local p1 = center + radialToCartesian(radius, 2*math.pi*i / segments)
    --    local p2 = center + radialToCartesian(radius, 2*math.pi*(i + 1) / segments)
    --    self.physics:add(entity.new(), love.physics.newEdgeShape(p1.x, p1.y, p2.x, p2.y), "static")
    --end

    return globe
end

return Scene
