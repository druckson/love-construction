local color = require "utils/color"
local vector = require "lib/hump/vector"
local entity = require "entity"
local display = require "display"
local player = require "player"
local construction = require "construction"

local worldSize = vector.new(5, 5)
local screenSize = vector.new(1366, 768)

function createJoinPoint(parent, color, x, y, r)
    local childBlock = entity.new(parent)
    childBlock.transform:setPosition(x, y)
    childBlock.transform:setRotation(r)
    --display:add(childBlock, "triangle", color, {radius=0.1})
    construction:add(childBlock)
end

function createBlock(color)
    local mainBlock = entity.new()
    mainBlock.transform:setPosition(
        math.random() * worldSize.x,
        math.random() * worldSize.y)

    mainBlock.transform:setRotation(
        math.random()*2*math.pi)
    
    display:add(mainBlock, "square", color, {size=1})
    
    createJoinPoint(mainBlock, {60, 00, 00, 255}, 0.5,  0, 0)
    createJoinPoint(mainBlock, {60, 60, 60, 255}, 0,  0.5, math.pi/2)
    createJoinPoint(mainBlock, {60, 60, 60, 255}, -0.5, 0, math.pi)
    createJoinPoint(mainBlock, {60, 60, 60, 255}, 0, -0.5, -math.pi/2)

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
    
    local gr = iterateGR(0)
    table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.5, 0.5, 0.5)))
    table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.5, 0.5, 0.5)))
    table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.5, 0.5, 0.5)))
    table.insert(parentBlocks, createBlock(color.HsvToRgb(gr(), 0.5, 0.5, 0.5)))

    locator = construction:connect(parentBlocks[1].transform.children[1].object,
                                   parentBlocks[2].transform.children[1].object)
    locator = construction:connect(parentBlocks[1].transform.children[2].object,
                                   parentBlocks[3].transform.children[1].object)
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

    local p1 = entity.new()
    p1.transform:setPosition(1, 1)
    display:add(p1, "square", {30, 90, 30, 255}, {size=1})
    player:set(p1, 1)
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
end

function love.draw()
    display:display()
end
