local vector = require "../lib/hump/vector"
local transform = require "../utils/transform"
local math = require "math"

local function compare(n1, n2)
    return math.abs(n1 - n2) < 0.0000001
end

describe("Transform tests", function()
    it("Test absolute transform", function()
        local parent = transform.new(nil)
        local child = transform.new(nil, parent)
        parent:setPosition(1, 0)
        parent:setRotation(math.pi/2)
        child:setPosition(0, 0)
        child:setRotation(0)

        print(child:getAbsoluteMatrix())
        child:setAbsolute()

        print(child)
        assert(compare(child.position.x, 1))
        assert(compare(child.position.y, 0))
        assert(compare(child.rotation, math.pi/2))
    end)

    it("Test relative transform", function()
        local parent = transform.new(nil)
        local child = transform.new(nil)
        parent:setPosition(1, 0)
        parent:setRotation(math.pi/2)

        child:setPosition(1, 0)
        child:setRotation(math.pi/2)

        child:setRelative(parent)

        print(child)
        assert(child.position.x == 0)
        assert(child.position.y == 0)
        assert(child.rotation == 0)
    end)
end)
