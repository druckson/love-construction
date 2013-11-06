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
local physics = systems.Physics(integrators.RK4)
local display = systems.Display()
local player = systems.Player(display)
local construction = systems.Construction()

engine:addSystem("physics",      physics)
engine:addSystem("display",      display)
engine:addSystem("player",       player)
engine:addSystem("construction", construction)

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
    dt = math.min(dt, 0.5)
    physics:update(dt)
    player:update(dt)
    engine.messaging:flush()
end

function love.draw()
    display:display()
end
