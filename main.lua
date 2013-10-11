local color = require "utils/color"
local vector = require "lib/hump/vector"
local entity = require "entity"
local display = require "display"
local player = require "player"
local construction = require "construction"
local physics = require "physics"

local worldSize = vector.new(10, 10)
local screenSize = vector.new(1366, 768)

function createJoinPoint(parent, color, x, y, r)
    local childBlock = entity.new(parent)
    childBlock.transform:setPosition(x, y)
    childBlock.transform:setRotation(r)
    --display:add(childBlock, "triangle", color, {radius=0.1})
    construction:add(childBlock)
end

function createBlock(color, isPlayer)
    local mainBlock = entity.new()
    mainBlock.transform:setPosition(
        math.random() * worldSize.x,
        math.random() * worldSize.y)

    mainBlock.transform:setRotation(
        math.random()*2*math.pi)
    
    display:add(mainBlock, "square", color, {size=1})
    physics:add(mainBlock, love.physics.newRectangleShape(0.5, 0.5), "dynamic")


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

local locator
local parentBlocks = {}

function iterateGR(start)
    local current = start
    return function()
        current = (current + 1.61803398875) % 1
        return current
    end
end

function test1()
    parentBlocks = {}
    --for i=0,1 do
    --    table.insert(parentBlocks, createBlock({90, 90, 90, 255}))
    --end
    --
    local wx = worldSize.x
    local wy = worldSize.y

    physics:add(entity.new(), love.physics.newEdgeShape( 0,  0, wx,  0), "static")
    physics:add(entity.new(), love.physics.newEdgeShape(wx,  0, wx, wy), "static")
    physics:add(entity.new(), love.physics.newEdgeShape(wx, wy,  0, wy), "static")
    physics:add(entity.new(), love.physics.newEdgeShape( 0, wy,  0,  0), "static")
    
    local gr = iterateGR(0)
    --table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), false))
    --table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), false))
    --table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), false))
    --table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), false))

    for i = 0, 50 do
        table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.7, 0.7, 1.0), false))
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

    local p1 = createBlock(color.HsvToRgb(0, 0.7, 0.7, 1.0), true)
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('quit') -- Quit the game.
    end 
    if k == 'e' then
        parentBlocks[2].transform:removeParent()
    end
end

function love.update(dt)
    player:update(dt)
    physics:update(dt)
end

function love.draw()
    display:display()
end
