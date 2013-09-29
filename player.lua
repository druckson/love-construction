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
    local moveSpeed = dt*100
    local moveForward = 0
    local moveSideways = 0

    if love.keyboard.isDown("w") then moveForward = moveForward - moveSpeed end
    if love.keyboard.isDown("s") then moveForward = moveForward + moveSpeed end
    if love.keyboard.isDown("d") then moveSideways = moveSideways - moveSpeed end
    if love.keyboard.isDown("a") then moveSideways = moveSideways + moveSpeed end

    local rotateSpeed = dt
    local rotate = 0
    if love.keyboard.isDown("q") then rotate = rotate - rotateSpeed end
    if love.keyboard.isDown("e") then rotate = rotate + rotateSpeed end

    local zoomSpeed = dt
    local zoom = 0
    if love.keyboard.isDown("x") then zoom = zoom + zoomSpeed end
    if love.keyboard.isDown("c") then zoom = zoom - zoomSpeed end

    self.object.transform.position = self.object.transform.position +
        vector.new(moveForward*math.sin(-self.object.transform.rotation) -
                   moveSideways*math.cos(-self.object.transform.rotation),
                   moveForward*math.cos(-self.object.transform.rotation) +
                   moveSideways*math.sin(-self.object.transform.rotation))
    self.object.transform.rotation = self.object.transform.rotation + rotate
    self.object.player.zoom = self.object.player.zoom + zoom

    display:moveCamera(self.object.transform.position.x,
                       self.object.transform.position.y)
    display:rotateCamera(self.object.transform.rotation)
    display:zoomCamera(self.object.player.zoom)
end

return Player
