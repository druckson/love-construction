local vector = require "lib/hump/vector"
local matrix = require "utils/matrix"
local Class = require "lib/hump/class"

local Player = Class{
    init = function(self, display)
        self.display = display
        self.object = {}
    end,
}

function Player:set(object, zoom)
    object.player = {
        zoom = zoom or 1,
        cameraAngle = object.transform.rotation
    }
    self.object = object
end

function Player:update(dt)
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

    --local velocity = vector.new(self.object.physics.body:getLinearVelocity()):normalized()
    --self.object.player.cameraAngle = math.pi + velocity:angleTo()
    self.object.player.cameraAngle = rotation

    local zoomSpeed = dt*50
    local zoom = 0
    if love.keyboard.isDown("x") then zoom = zoom + zoomSpeed end
    if love.keyboard.isDown("c") then zoom = zoom - zoomSpeed end

    local velocity = matrix.rotate(self.object.player.cameraAngle) *
                     vector.new(-moveSideways, moveForward)

    self.object.physics.body:applyForce(velocity:unpack())
    --self.object.physics.body:applyTorque(self.object.player.cameraAngle - rotation)
    self.object.player.zoom = math.max(0.01, math.min(1000, self.object.player.zoom + zoom))

    self.display:moveCamera(self.object.transform.position.x,
                            self.object.transform.position.y)

    self.display:rotateCamera(self.object.player.cameraAngle)
    self.display:zoomCamera(self.object.player.zoom)
    self.display:setSpeedometer(vector.new(self.object.physics.body:getLinearVelocity()):len())
end

return Player
