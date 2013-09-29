local vector = require "hump/vector"
local transform = require "transform"
local display = require "display"

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
        
        display:add(mainBlock, "square", {50, 50, 50, 255}, {size=20})

        local childBlock = {}
        transform:add(childBlock, 10, 0, 0, mainBlock)
        display:add(childBlock, "square", {100, 100, 100, 255}, {size=5})
    end
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('quit') -- Quit the game.
    end 
end

function love.update(dt)
    local moveSpeed = dt*30
    if love.keyboard.isDown("w") then display:moveCamera( 0,  moveSpeed) end
    if love.keyboard.isDown("s") then display:moveCamera( 0, -moveSpeed) end
    if love.keyboard.isDown("a") then display:moveCamera( moveSpeed,  0) end
    if love.keyboard.isDown("d") then display:moveCamera(-moveSpeed,  0) end

    local rotateSpeed = dt
    if love.keyboard.isDown("q") then display:rotateCamera( rotateSpeed) end
    if love.keyboard.isDown("e") then display:rotateCamera(-rotateSpeed) end

    local zoomSpeed = dt
    if love.keyboard.isDown("x") then display:zoomCamera( zoomSpeed) end
    if love.keyboard.isDown("c") then display:zoomCamera(-zoomSpeed) end
end

function love.draw()
    display:display()
end
