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
    init = function(self, engine)
        local gr = iterateGR(0)

        self:createBlock(engine, {0, 0}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, math.random()*2*math.pi, 1, true)
        for i = 0, 50 do
            self:createBlock(engine, {200, 0}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, math.random()*2*math.pi, 1, false)
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

function Scene:createBlock(engine, position, color, rotation, density, isPlayer, velocity)
    local mainBlock = {
        transform = {
            position = position,
            rotation = 0
        },
        physics = {
            bodyType = "dynamic",
            density = density,
            shape = {
                type = "square",
                sideLength = 1
            }
        },
        display = {
            color = color,
            shape = {
                type = "square",
                sideLength = 1
            }
        }
    }

    if velocity then
        mainBlock.physics.velocity = velocity
    end

    if isPlayer then
        mainBlock.player = {
            zoom = 1
        }
    else
        --self.createJoinPoint(mainBlock, {60, 00, 00, 255}, 0.5,  0, 0)
        --self.createJoinPoint(mainBlock, {60, 60, 60, 255}, 0,  0.5, math.pi/2)
        --self.createJoinPoint(mainBlock, {60, 60, 60, 255}, -0.5, 0, math.pi)
        --self.createJoinPoint(mainBlock, {60, 60, 60, 255}, 0, -0.5, -math.pi/2)
    end

    engine:createEntity(mainBlock)
end

return Scene
