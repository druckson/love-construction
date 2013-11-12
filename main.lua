local color = require "utils/color"
local vector = require "lib/hump/vector"
local entity = require "entity"
local systems = require "systems"
local integrators = require "utils/integrators"
local scenes = require "scenes"
local Engine = require "engine"

local ProFi = require "lib/profi"

local mode = love.graphics.getModes()[1]
local worldSize = vector.new(1000, 1000)
local screenSize = vector.new(mode.width, mode.height)

local engine = Engine()
local physics = systems.Physics(integrators.Euler, 5)
local display = systems.Display()
local player = systems.Player(display)
local construction = systems.Construction()
local electricity = systems.Electricity()
local light = systems.Light()
local generator = systems.Generator()
local thruster = systems.Thruster()

engine:addSystem("physics",      physics)
engine:addSystem("player",       player)
engine:addSystem("display",      display)
engine:addSystem("construction", construction)
engine:addSystem("electricity",  electricity)
engine:addSystem("light",        light)
engine:addSystem("generator",    generator)
engine:addSystem("thruster",     thruster)

function love.load()
    ProFi:start()
    display:setScreenSize(screenSize.x, screenSize.y)
    local scene = scenes.Scene3(engine)
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.push('quit') -- Quit the game.
        ProFi:stop()
        ProFi:writeReport("perf.txt")
    end 
end

function love.update(dt)
    engine:update(dt)
    engine.messaging:flush()
end

function love.draw()
    display:display()
end
