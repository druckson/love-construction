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

        
        self:createBlock(engine, {0, 0}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, 0, 1, true)
        for x = 1, 5 do
            for y = 1, 5 do
                if true then --math.random() < 0.5 then
                    self:createBlock(engine, {x*2, y*2}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, 0, 1, false)
                else
                    self:createTriangle(engine, {x*2, y*2}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, 0, 1, false)
                end
            end
        end
        self:createBoundingBox(engine, 50)

        --self:createTriangle(engine, {0, 0}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, math.random()*2*math.pi, 1, true)
        --for x = 1, 1 do
        --    for y = 1, 1 do
        --        self:createTriangle(engine, {x*2, y*2}, {space="hsva", h=gr(), s=0.7, v=0.7, a=1.0}, math.random()*2*math.pi, 1, false)
        --    end
        --end
    end
}

function Scene:createBoundingBox(engine, l)
    self:createStaticBox(engine, {  0, -l/2}, {space="hsva", h=0, s=0.7, v=0.7, a=1.0},  0, l, 1)
    self:createStaticBox(engine, {  0,  l/2}, {space="hsva", h=0, s=0.7, v=0.7, a=1.0},  0, l, 1)
    self:createStaticBox(engine, {-l/2,   0}, {space="hsva", h=0, s=0.7, v=0.7, a=1.0},  0, 1, l)
    self:createStaticBox(engine, { l/2,   0}, {space="hsva", h=0, s=0.7, v=0.7, a=1.0},  0, 1, l)
end

function Scene:createStaticBox(engine, position, color, rotation, width, height)
    local mainBlock = {
        transform = {
            position = position,
            rotation = rotation 
        },
        physics = {
            bodyType = "static",
            density = density,
            shape = {
                type = "rectangle",
                width = width,
                height = height
            }
        },
        display = {
            color = color,
            shape = {
                type = "rectangle",
                width = width,
                height = height
            }
        }
    }

    engine:createEntity(mainBlock)
end

function Scene:createJoinPoint(engine, parent, position, color, rotation)
    local childBlock = {
        transform = {
            parent = parent,
            position = position,
            rotation = rotation
        },
        physics = {
            bodyType = "dynamic",
            density = 1,
            sensor = true,
            shape = {
                type = "circle",
                segments = 7,
                radius = 0.03
            }
        },
        --display = {
        --    color = color,
        --    shape = {
        --        type = "triangle",
        --        radius = 0.1
        --    }
        --},
        construction = {
            type = "socket"
        }
    }
    engine:createEntity(childBlock)
end

function Scene:createTriangle(engine, position, color, rotation, density, isPlayer, velocity)
    local mainBlock = {
        transform = {
            position = position,
            rotation = rotation 
        },
        physics = {
            bodyType = "dynamic",
            density = density,
            shape = {
                type = "triangle",
                radius = 1
            }
        },
        display = {
            color = color,
            shape = {
                type = "triangle",
                radius = 1
            }
        }
    }
    if isPlayer then
        mainBlock.player = {
            zoom = 1
        }

        engine:createEntity(mainBlock)

    else
        local entity = engine:createEntity(mainBlock)

        local angle = 0
        local point = vector.new(1, 0)

        for i = 0, 3 do
            self:createJoinPoint(engine, entity.transform,
                                {point:rotated(angle):unpack()},
                                {space="rgba", r=60, g=60, b=60, a=255},
                                angle)
            angle = angle + (2*math.pi/3)
        end
    end

end

function Scene:createBlock(engine, position, color, rotation, density, isPlayer, velocity)
    local mainBlock = {
        transform = {
            position = position,
            rotation = rotation 
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
