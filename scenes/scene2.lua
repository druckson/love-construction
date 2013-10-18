local matrix = require "utils/matrix"
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

        self:createGlobe(engine, {    0, 0}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, 500,  0, 1)
        self:createGlobe(engine, { 5000, 0}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, 100, 20, 1, {0, -50})
        self:createGlobe(engine, {-5000, 0}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, 100, 20, 1, {0,  50})
        self:createBlock(engine, { 5150, 0}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, math.random()*2*math.pi, 1, true, {0, -45})
    end
}

function Scene:createJoinPoint(parent, color, x, y, r)
    local childBlock = entity.new(parent)
    childBlock.transform:setPosition(x, y)
    childBlock.transform:setRotation(r)
    --display:add(childBlock, "triangle", color, {radius=0.1})
    construction:add(childBlock)
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

function Scene:createGlobe(engine, position, color, radius, atmosphere_level, density, velocity)
    local globe = {
        transform = {
            position = position,
            rotation = 0
        },
        physics = {
            bodyType = "dynamic",
            density = density,
            velocity = {10, 0},
            shape = {
                type = "circle",
                radius = radius
            },
            gravity = {
                atmosphere = {
                    radius = radius,
                    level = atmosphere_level,
                    density = 1.0
                }
            }
        },
        display = {
            shape = {
                type = "circle",
                radius = radius
            },
            color = color
        }
    }

    if velocity ~= nil then
        globe.physics.velocity = velocity
    end

    engine:createEntity(globe)
end

return Scene
