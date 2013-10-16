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
    init = function(self, display, physics, player, construction)
        self.display = display
        self.physics = physics
        self.player =  player
        self.construction = construction

        local gr = iterateGR(0)

        self.player1 = self:createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), vector.new(0, 0), true)
        for i = 0, 50 do
            self:createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), vector.new(200, 0), false)
        end
    end
}

function Scene:createJoinPoint(parent, color, x, y, r)
    local childBlock = entity.new(parent)
    childBlock.transform:setPosition(x, y)
    childBlock.transform:setRotation(r)
    --display:add(childBlock, "triangle", color, {radius=0.1})
    self.construction:add(childBlock)
end

function Scene:createBlock(color, position, isPlayer, velocity)
    local mainBlock = entity.new()
    mainBlock.transform:setPosition(position:unpack())

    mainBlock.transform:setRotation(
        math.random()*2*math.pi)
    
    self.display:add(mainBlock, "square", color, {size=1})
    self.physics:add(mainBlock, love.physics.newRectangleShape(0.5, 0.5), "dynamic")
    if velocity then
        mainBlock.physics.body:setLinearVelocity(velocity:unpack())
    end


    if isPlayer then
        self.player:set(mainBlock, 1)
    else
        self:createJoinPoint(mainBlock, {60, 00, 00, 255}, 0.5,  0, 0)
        self:createJoinPoint(mainBlock, {60, 60, 60, 255}, 0,  0.5, math.pi/2)
        self:createJoinPoint(mainBlock, {60, 60, 60, 255}, -0.5, 0, math.pi)
        self:createJoinPoint(mainBlock, {60, 60, 60, 255}, 0, -0.5, -math.pi/2)
    end

    return mainBlock
end

return Scene
