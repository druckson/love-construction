local vector = require "hump/vector"
local transform = require "transform"
local display = require "display"
local player = require "player"
local construction = require "construction"

local worldSize = vector.new(10, 10)
local screenSize = vector.new(1366, 768)

function createBlock()
    local mainBlock = {}
    transform:add(mainBlock, 
        math.random(worldSize.x),
        math.random(worldSize.y),
        math.random(math.pi))
    
    display:add(mainBlock, "square", {90, 90, 90, 255}, {size=1})
    
    local childBlock = {}
    transform:add(childBlock, 0.5, 0, 0, mainBlock)
    display:add(childBlock, "triangle", {60, 60, 60, 255}, {radius=0.1})
    construction:add(childBlock)

    childBlock = {}
    transform:add(childBlock, 0, 0.5, math.pi/2, mainBlock)
    display:add(childBlock, "triangle", {60, 60, 60, 255}, {radius=0.1})
    construction:add(childBlock)
    
    childBlock = {}
    transform:add(childBlock, -0.5, 0, math.pi, mainBlock)
    display:add(childBlock, "triangle", {60, 60, 60, 255}, {radius=0.1})
    construction:add(childBlock)
    
    childBlock = {}
    transform:add(childBlock, 0, -0.5, 3*math.pi/2, mainBlock)
    display:add(childBlock, "triangle", {60, 60, 60, 255}, {radius=0.1})
    construction:add(childBlock)
end

function love.load()   
    display:setScreenSize(screenSize.x, screenSize.y)

    local world = {}
    transform:add(world, worldSize.x/2, worldSize.y/2, 0)
    display:add(world, "rect", {200, 200, 200, 255}, {size=worldSize})

    for i=0,1 do
        createBlock()
    end

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
