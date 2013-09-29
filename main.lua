local vector = require "hump/vector"
local transform = require "transform"
local display = require "display"
local player = require "player"

local world = {
    width = 300,
    height = 300
}

function love.load()   
    love.graphics.setMode(300, 300, false, true, 3)
    for i=0,10 do
        local mainBlock = {}
        transform:add(mainBlock, 
            math.random(world.width),
            math.random(world.height),
            math.random(math.pi))
        
        display:add(mainBlock, "square", {90, 90, 90, 255}, {size=20})

        local childBlock = {}
        transform:add(childBlock, 10, 0, 0, mainBlock)
        display:add(childBlock, "square", {60, 60, 60, 255}, {size=5})
    end

    local p1 = {}
    transform:add(p1, 
        math.random(world.width),
        math.random(world.height),
        math.random(math.pi))
    display:add(p1, "square", {90, 90, 90, 255}, {size=10})
    player:set(p1)
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
