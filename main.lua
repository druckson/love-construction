local vector = require "lib/hump/vector"
local object = require "object"
local display = require "display"
local player = require "player"
local construction = require "construction"

local worldSize = vector.new(10, 10)
local screenSize = vector.new(1366, 768)

function createBlock()
    local mainBlock = object.new()
    mainBlock.transform:setPosition(
        math.random(worldSize.x),
        math.random(worldSize.y))
    mainBlock.transform:setRotation(
        math.random(math.pi))
    
    display:add(mainBlock, "square", {90, 90, 90, 255}, {size=1})
    
    local childBlock = object.new(mainBlock)
    childBlock.transform:setPosition(0.5, 0)
    display:add(childBlock, "triangle", {60, 60, 60, 255}, {radius=0.1})
    construction:add(childBlock)

    childBlock = object.new(mainBlock)
    childBlock.transform:setPosition(0, 0.5)
    childBlock.transform:setRotation(math.pi/2)
    display:add(childBlock, "triangle", {60, 60, 60, 255}, {radius=0.1})
    construction:add(childBlock)
    
    childBlock = object.new(mainBlock)
    childBlock.transform:setPosition(-0.5, 0)
    childBlock.transform:setRotation(math.pi)
    display:add(childBlock, "triangle", {60, 60, 60, 255}, {radius=0.1})
    construction:add(childBlock)
    
    childBlock = object.new(mainBlock)
    childBlock.transform:setPosition(0, 0.5)
    childBlock.transform:setRotation(3*math.pi/2)
    display:add(childBlock, "triangle", {60, 60, 60, 255}, {radius=0.1})
    construction:add(childBlock)
    return mainBlock
end

function love.load()   
    display:setScreenSize(screenSize.x, screenSize.y)

    local world = object.new()
    world.transform:setPosition(worldSize.x/2, worldSize.y/2)
    display:add(world, "rect", {200, 200, 200, 255}, {size=worldSize})

    local parentBlocks = {}
    for i=0,1 do
        table.insert(parentBlocks, createBlock())
    end

    print(parentBlocks[1].transform)
    construction:connect(parentBlocks[1].transform.children[1],
                         parentBlocks[2].transform.children[1])

    local p1 = {}
    transform:add(p1, 
        math.random(worldSize.x),
        math.random(worldSize.y),
        0)
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
