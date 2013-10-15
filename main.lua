local color = require "utils/color"
local vector = require "lib/hump/vector"
local entity = require "entity"
local systems = require "systems"
local integrators = require "utils/integrators"
local scenes = require "scenes"

local mode = love.graphics.getModes()[1]
local worldSize = vector.new(1000, 1000)
local screenSize = vector.new(mode.width, mode.height)

local physics = systems.Physics(integrators.RK4)
local display = systems.Display()
local player = systems.Player(display)
local construction = systems.Construction()

function love.load()   
    display:setScreenSize(screenSize.x, screenSize.y)
    local scene = scenes.Scene1(display, physics, player, construction)
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
