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
        for i = 0, 2 do
            self:createBlock(engine, {20, 0}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, math.random()*2*math.pi, 1, false)
        end
    end
}

function Scene:createJoinPoint(engine, parent, position, color, rotation)
    --local childBlock = entity.new(parent)
    --childBlock.transform:setPosition(x, y)
    --childBlock.transform:setRotation(r)
    ----display:add(childBlock, "triangle", color, {radius=0.1})
    --self.construction:add(childBlock)

    local childBlock = {
        transform = {
            parent = parent,
            position = position,
            rotation = rotation
        },
        physics = {
            bodyType = "dynamic",
            density = 1,
            shape = {
                type = "circle",
                radius = 0.1
            }
        },
        display = {
            color = color,
            shape = {
                type = "triangle",
                radius = 0.1
            }
        },
        construction = {}
    }
    engine:createEntity(childBlock)
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

        engine:createEntity(mainBlock)
    else
        local entity = engine:createEntity(mainBlock)
        self:createJoinPoint(engine, entity.transform, { 0.5,    0}, {space="rgba", r=60, g=00, b=00, a=255}, 0)
        self:createJoinPoint(engine, entity.transform, {   0,  0.5}, {space="rgba", r=60, g=60, b=60, a=255}, math.pi/2)
        self:createJoinPoint(engine, entity.transform, {-0.5,    0}, {space="rgba", r=60, g=60, b=60, a=255}, math.pi)
        self:createJoinPoint(engine, entity.transform, {   0, -0.5}, {space="rgba", r=60, g=60, b=60, a=255}, -math.pi/2)
    end
end

return Scene
