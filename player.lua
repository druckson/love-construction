local vector = require "../hump/vector"
local display = require "display"

local Player = {
    object = {}
}

function Player:set(object, zoom)
    object.player = {
        zoom = zoom or 1
    }
    self.object = object
end

function Player:update(dt)
    local moveSpeed = dt*10
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

    local zoomSpeed = dt*10
    local zoom = 0
    if love.keyboard.isDown("x") then zoom = zoom + zoomSpeed end
    if love.keyboard.isDown("c") then zoom = zoom - zoomSpeed end

    self.object.transform.position = self.object.transform.position +
        vector.new(moveForward*math.sin(-self.object.transform.rotation) -
                   moveSideways*math.cos(-self.object.transform.rotation),
                   moveForward*math.cos(-self.object.transform.rotation) +
                   moveSideways*math.sin(-self.object.transform.rotation))
    self.object.transform.rotation = rotation
    self.object.player.zoom = self.object.player.zoom + zoom

    display:moveCamera(self.object.transform.position.x,
                       self.object.transform.position.y)
    display:rotateCamera(self.object.transform.rotation)
    display:zoomCamera(self.object.player.zoom)
end

return Player
