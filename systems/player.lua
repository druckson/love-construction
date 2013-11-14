local vector = require "lib/hump/vector"
local matrix = require "utils/matrix"
local Class = require "lib/hump/class"

local Player = Class{
    init = function(self, display)
        self.display = display
    end,
}

function Player:setup(engine)
    self.engine = engine
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
        local moveSpeed = 0.2
        local moveForward = 0
        local moveSideways = 0

        local turnSpeed = 0.1
        local turn = 0

        if love.keyboard.isDown("w") then moveForward = moveForward - moveSpeed end
        if love.keyboard.isDown("s") then moveForward = moveForward + moveSpeed end
        if love.keyboard.isDown("d") then moveSideways = moveSideways - moveSpeed end
        if love.keyboard.isDown("a") then moveSideways = moveSideways + moveSpeed end

        if love.keyboard.isDown("q") then turn = turn - turnSpeed end
        if love.keyboard.isDown("e") then turn = turn + turnSpeed end

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

        local zoomSpeed = dt*1
        local zoom = 0
        if love.keyboard.isDown("x") then zoom = zoom + zoomSpeed end
        if love.keyboard.isDown("c") then zoom = zoom - zoomSpeed end

        local velocity = matrix.rotate(self.entity.player.cameraAngle) *
                         vector.new(-moveSideways, moveForward)

        local parent = self.entity.transform:getBaseAncestor().entity

        if self.entity.electricity then
            velocity = velocity * self.entity.electricity.draw
            turn = turn * self.entity.electricity.draw
        end

        parent.physics.body:applyForce(velocity:unpack())
        parent.physics.body:applyTorque(turn)
        --self.entity.physics.body:applyTorque(self.entity.player.cameraAngle - rotation)
        self.entity.player.zoom = math.max(0.01, math.min(1000, self.entity.player.zoom + zoom))

        self.display:moveCamera(parent.transform.position.x,
                                parent.transform.position.y)

        self.display:rotateCamera(self.entity.player.cameraAngle)
        self.display:zoomCamera(self.entity.player.zoom)
        self.display:setSpeedometer(vector.new(parent.physics.body:getLinearVelocity()):len())

        if self.entity.generator then
            self.display:setFuel(self.entity.generator.fuel)
        end
        if self.entity.electricity then
            self.display:setBattery(self.entity.electricity.outputCharge)
        end
    end
end

return Player
