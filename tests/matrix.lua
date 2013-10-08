local vector = require "../lib/hump/vector"
local matrix = require "../utils/matrix"
local math = require "math"

local function compare(n1, n2)
    return math.abs(n1 - n2) < 0.0000001
end

describe("Matrix tests", function()
    it("Test identity", function()
        local m = matrix.new()
        assert.is_not_nil(m)
    
        assert(m[1][1] == 1)
        assert(m[1][2] == 0)
        assert(m[1][3] == 0)
    
        assert(m[2][1] == 0)
        assert(m[2][2] == 1)
        assert(m[2][3] == 0)
    
        assert(m[3][1] == 0)
        assert(m[3][2] == 0)
        assert(m[3][3] == 1)
    end)
    
    it("Test mult", function()
        local m1 = matrix.new()
        local m2 = matrix.new()
        local m3 = m1 * m2
        assert.is_not_nil(m3)
    
        assert(m3[1][1] == 1)
        assert(m3[1][2] == 0)
        assert(m3[1][3] == 0)
    
        assert(m3[2][1] == 0)
        assert(m3[2][2] == 1)
        assert(m3[2][3] == 0)
    
        assert(m3[3][1] == 0)
        assert(m3[3][2] == 0)
        assert(m3[3][3] == 1)
    end)
    
    it("Test vector multiplication", function()
        local m1 = matrix.new()
        local v1 = vector.new(1, 2)
        local v2 = m1 * v1
    
        assert.is_not_nil(v2)
        assert(v2.x == 1)
        assert(v2.y == 2)
    end)
    
    it("Test scale", function()
        local m1 = matrix.scale(2)
        local v1 = vector.new(1, 2)
        local v2 = m1 * v1
    
        assert.is_not_nil(v2)
        assert(v2.x == 2)
        assert(v2.y == 4)
    end)
    
    it("Test translate", function()
        local m1 = matrix.translate(1, 1)
        local v1 = vector.new(1, 2)
        local v2 = m1 * v1
    
        assert.is_not_nil(v2)
        assert(v2.x == 2)
        assert(v2.y == 3)
    end)

    it("Test rotation", function()
        local m1 = matrix.rotate(math.pi)
        local v1 = vector.new(1, 2)
        local v2 = m1 * v1

        assert.is_not_nil(v2)
        assert.is_true(compare(v2.x, -1))
        assert.is_true(compare(v2.y, -2))
    end)

    it("Test print", function()
        local m1 = matrix.translate(1, 2) * matrix.rotate(1)
        local m2 = matrix.translate(5, 3) * matrix.rotate(3)
        print(m1)
        print(m2)
        print(m1 * m2)
    end)
end)
