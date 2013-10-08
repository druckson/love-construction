local vector = require "lib/hump/vector"
local entity = require "entity"
local display = require "display"
local player = require "player"
local construction = require "construction"

local worldSize = vector.new(100, 100)
local screenSize = vector.new(1366, 768)

function createJoinPoint(parent, x, y, r)
    local childBlock = entity.new(parent)
    childBlock.transform:setPosition(x, y)
    childBlock.transform:setRotation(r)
    display:add(childBlock, "triangle", {60, 60, 60, 255}, {radius=0.1})
    construction:add(childBlock)
end

function createBlock()
    local mainBlock = entity.new()
    mainBlock.transform:setPosition(
        math.random(worldSize.x),
        math.random(worldSize.y))
    mainBlock.transform:setRotation(
        math.random(math.pi))
    
    display:add(mainBlock, "square", {90, 90, 90, 255}, {size=1})
    
    createJoinPoint(mainBlock, 0.5,  0, 0)
    createJoinPoint(mainBlock, 0,  0.5, math.pi/2)
    createJoinPoint(mainBlock, -0.5, 0, math.pi)
    createJoinPoint(mainBlock, 0, -0.5, 3*math.pi/2)

    return mainBlock
end

function test1()
    local parentBlocks = {}
    for i=0,1000 do
        table.insert(parentBlocks, createBlock())
    end

    construction:connect(parentBlocks[1].transform.children[1],
                         parentBlocks[2].transform.children[1])
end

function test2()
    local parentBlocks = {}
    for i=0,1 do
        table.insert(parentBlocks, createBlock())
    end

    construction:connect(parentBlocks[1].transform.children[1],
                         parentBlocks[2].transform.children[1])
end

function love.load()   
    display:setScreenSize(screenSize.x, screenSize.y)

    local world = entity.new()
    world.transform:setPosition(worldSize.x/2, worldSize.y/2)
    display:add(world, "rect", {200, 200, 200, 255}, {size=worldSize})

    test1()

    local p1 = entity.new()
    p1.transform:setPosition(1, 1)
    display:add(p1, "square", {30, 90, 30, 255}, {size=1})
    player:set(p1, 1)
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('quit') -- Quit the game.
    end 
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    display:display()
end
