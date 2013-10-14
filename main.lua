local color = require "utils/color"
local class = require "lib/hump/class"
local matrix = require "utils/matrix"
local vector = require "lib/hump/vector"
local entity = require "entity"
local systems = require "systems"
local integrators = require "utils/integrators"

local mode = love.graphics.getModes()[1]
local worldSize = vector.new(1000, 1000)
local screenSize = vector.new(mode.width, mode.height)

local physics = systems.Physics(integrators.RK4)
local display = systems.Display()
local player = systems.Player(display)
local construction = systems.Construction()

function createJoinPoint(parent, color, x, y, r)
    local childBlock = entity.new(parent)
    childBlock.transform:setPosition(x, y)
    childBlock.transform:setRotation(r)
    --display:add(childBlock, "triangle", color, {radius=0.1})
    construction:add(childBlock)
end

function createBlock(color, position, isPlayer, velocity)
    local mainBlock = entity.new()
    mainBlock.transform:setPosition(position:unpack())

    mainBlock.transform:setRotation(
        math.random()*2*math.pi)
    
    display:add(mainBlock, "square", color, {size=1})
    physics:add(mainBlock, love.physics.newRectangleShape(0.5, 0.5), "dynamic")
    if velocity then
        mainBlock.physics.body:setLinearVelocity(velocity:unpack())
    end


    if isPlayer then
        player:set(mainBlock, 1)
    else
        createJoinPoint(mainBlock, {60, 00, 00, 255}, 0.5,  0, 0)
        createJoinPoint(mainBlock, {60, 60, 60, 255}, 0,  0.5, math.pi/2)
        createJoinPoint(mainBlock, {60, 60, 60, 255}, -0.5, 0, math.pi)
        createJoinPoint(mainBlock, {60, 60, 60, 255}, 0, -0.5, -math.pi/2)
    end

    return mainBlock
end

function createGlobe(center, color, radius)
    local globe = entity.new()
    globe.transform:setPosition(center:unpack())
    display:add(globe, "circle", color, {radius=radius})
    physics:addGravity(center.x, center.y, 0.01*radius*radius)
    
    local segments = 100
    local translate = matrix.translate(worldSize.x / 2, worldSize.y / 2)
    for i = 0, segments do
        local p1 = center + radialToCartesian(radius, 2*math.pi*i / segments)
        local p2 = center + radialToCartesian(radius, 2*math.pi*(i + 1) / segments)
        physics:add(entity.new(), love.physics.newEdgeShape(p1.x, p1.y, p2.x, p2.y), "static")
    end

    return globe
end

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

function test1()
    parentBlocks = {}
    --for i=0,1 do
    --    table.insert(parentBlocks, createBlock({90, 90, 90, 255}))
    --end
    --
    local wx = worldSize.x
    local wy = worldSize.y

    local gr = iterateGR(0)

    local center = worldSize * 0.5
    local radius = math.min(worldSize.x, worldSize.y) * 0.3
    createGlobe(center, {60, 60, 60, 255}, radius)

    --physics:add(entity.new(), love.physics.newEdgeShape( 0,  0, wx,  0), "static")
    --physics:add(entity.new(), love.physics.newEdgeShape(wx,  0, wx, wy), "static")
    --physics:add(entity.new(), love.physics.newEdgeShape(wx, wy,  0, wy), "static")
    --physics:add(entity.new(), love.physics.newEdgeShape( 0, wy,  0,  0), "static")

    --table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), vector.new(math.random(wx), math.random(wy)), false))
    --table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), vector.new(math.random(wx), math.random(wy)), false))
    --table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), vector.new(math.random(wx), math.random(wy)), false))
    --table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), vector.new(math.random(wx), math.random(wy)), false))
    
    local gr = iterateGR(0)

    for i = 0, 300 do
        table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), vector.new(500, 50), false, vector.new(-30, 0)))
    end

    for i = 0, 300 do
        table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), vector.new(500, 950), false, vector.new(30, 0)))
    end

    --locator = construction:connect(parentBlocks[1].transform.children[1].object,
    --                               parentBlocks[2].transform.children[1].object)
    --locator = construction:connect(parentBlocks[1].transform.children[2].object,
    --                               parentBlocks[3].transform.children[1].object)
end

function test2()
    local parentBlocks = {}
    for i=0,1 do
        table.insert(parentBlocks, createBlock())
    end



    
end

function love.load()   
    display:setScreenSize(screenSize.x, screenSize.y)

    local world = entity.new()
    world.transform:setPosition(worldSize.x/2, worldSize.y/2)
    display:add(world, "rect", {200, 200, 200, 255}, {size=worldSize})

    test1()

    local p1 = createBlock(color.HsvToRgb(0, 0.7, 0.7, 1.0), vector.new(600, 0), true, vector.new(-30, 0))
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('quit') -- Quit the game.
    end 
end

function love.update(dt)
    physics:update(dt)
    player:update(dt)
end

function love.draw()
    display:display()
end
