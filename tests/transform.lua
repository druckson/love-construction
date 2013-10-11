local vector = require "../lib/hump/vector"
local transform = require "../utils/transform"
local math = require "math"

local function compare(n1, n2)
    return math.abs(n1 - n2) < 0.0000001
end

describe("Transform tests", function()
    describe("Absolute transform", function()
        it("Test absolute transform", function()
            local parent = transform.new(nil)
            local child = transform.new(nil, parent)
            parent:setPosition(0, 1)
            parent:setRotation(math.pi/2)
            child:setPosition(0, 1)
            child:setRotation(0)
            child:removeParent()

            assert(compare(child.position.x, 1))
            assert(compare(child.position.y, 1))
            assert(compare(child.rotation, math.pi/2))
        end)
    end)

    describe("Relative transform", function()
        it("Identity parent", function()
            local parent = transform.new(nil)
            local child = transform.new(nil)
            parent:setPosition(0, 0)
            parent:setRotation(0)

            child:setPosition(1, 0)
            child:setRotation(math.pi/2)

            child:setRelative(parent)

            assert(compare(child.position.x, 1))
            assert(compare(child.position.y, 0))
            assert(compare(child.rotation, math.pi/2))
        end)

        it("Parent equals child", function()
            local parent = transform.new(nil)
            local child = transform.new(nil)
            parent:setPosition(1, 0)
            parent:setRotation(math.pi/2)

            child:setPosition(1, 0)
            child:setRotation(math.pi/2)

            child:setRelative(parent)

            assert(compare(child.position.x, 0))
            assert(compare(child.position.y, 0))
            assert(compare(child.rotation, 0))
        end)

        it("Complex example", function()
            local parent = transform.new(nil)
            local child = transform.new(nil)
            parent:setPosition(0, 1)
            parent:setRotation(math.pi/2)

            child:setPosition(1, 1)
            child:setRotation(0)

            child:setRelative(parent)

            print(child.position)
            print(child.rotation)

            assert(compare(child.position.x, 0))
            assert(compare(child.position.y, 1))
            assert(compare(child.rotation, 3*math.pi/2))
        end)
    end)
end)
