local vector = require "lib/hump/vector"
local matrix = require "utils/matrix"
local Class = require "lib/hump/class"

local Player = Class{
    init = function(self, display)
        self.display = display
    end,
}

function Player:setup(engine)
    local player = self
    engine.registry:register("init_entity", function(...)
        player:init_entity(...)
    end)
    engine.registry:register("remove_entity", function(...)
        player:remove_entity(...)
    end)
end

function Player:init_entity(entity, object)
    entity.player = {
        zoom = object.zoom or 1,
        cameraAngle = entity.transform.rotation
    }
    self.entity = entity
end

function Player:remove_entity(entity)
    if self.entity == entity then
        self.entity = nil
        table.remove(entity, "player")
    end
end

function Player:update(dt)
    if self.entity ~= nil then
        local moveSpeed = 0.001
        local moveForward = 0
        local moveSideways = 0

        if love.keyboard.isDown("w") then moveForward = moveForward - moveSpeed end
        if love.keyboard.isDown("s") then moveForward = moveForward + moveSpeed end
        if love.keyboard.isDown("d") then moveSideways = moveSideways - moveSpeed end
        if love.keyboard.isDown("a") then moveSideways = moveSideways + moveSpeed end

        local rotation = love.mouse.getX() * 0.005
        if rotation > math.pi*2 then
            love.mouse.setPosition(
                love.mouse.getX() - (math.pi*2)/0.005,
                love.mouse.getY())
        elseif rotation <= 0 then
            love.mouse.setPosition(
                love.mouse.getX() + (math.pi*2)/0.005,
                love.mouse.getY())
        end

        --local velocity = vector.new(self.entity.physics.body:getLinearVelocity()):normalized()
        --self.entity.player.cameraAngle = math.pi + velocity:angleTo()
        self.entity.player.cameraAngle = rotation

        local zoomSpeed = dt*50
        local zoom = 0
        if love.keyboard.isDown("x") then zoom = zoom + zoomSpeed end
        if love.keyboard.isDown("c") then zoom = zoom - zoomSpeed end

        local velocity = matrix.rotate(self.entity.player.cameraAngle) *
                         vector.new(-moveSideways, moveForward)

        self.entity.physics.body:applyForce(velocity:unpack())
        --self.entity.physics.body:applyTorque(self.entity.player.cameraAngle - rotation)
        self.entity.player.zoom = math.max(0.01, math.min(1000, self.entity.player.zoom + zoom))

        self.display:moveCamera(self.entity.transform.position.x,
                                self.entity.transform.position.y)

        self.display:rotateCamera(self.entity.player.cameraAngle)
        self.display:zoomCamera(self.entity.player.zoom)
        self.display:setSpeedometer(vector.new(self.entity.physics.body:getLinearVelocity()):len())
    end
end

return Player
