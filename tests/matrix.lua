require "lunit"
local vector = require "../lib/hump/vector"
local matrix = require "../utils/matrix"
local math = require "math"

module("matrix", lunit.testcase)

function test_setup()
    local m = matrix.new()
    assert(m ~= nil)
end

function test_func()
    local m = matrix.new()
    assert(m.getRow ~= nil)
end

function test_value()
    local m = matrix.new()
    assert(m[1] ~= nil)
    assert(m[2] ~= nil)
    assert(m[3] ~= nil)
end

function test_identity()
    local m = matrix.new()

    assert(m[1][1] == 1)
    assert(m[1][2] == 0)
    assert(m[1][3] == 0)

    assert(m[2][1] == 0)
    assert(m[2][2] == 1)
    assert(m[2][3] == 0)

    assert(m[3][1] == 0)
    assert(m[3][2] == 0)
    assert(m[3][3] == 1)
end

function test_mult()
    local m1 = matrix.new()
    local m2 = matrix.new()
    local m3 = m1 * m2
    assert(m3 ~= nil)

    assert(m3[1][1] == 1)
    assert(m3[1][2] == 0)
    assert(m3[1][3] == 0)

    assert(m3[2][1] == 0)
    assert(m3[2][2] == 1)
    assert(m3[2][3] == 0)

    assert(m3[3][1] == 0)
    assert(m3[3][2] == 0)
    assert(m3[3][3] == 1)
end

function test_vecMult()
    local m1 = matrix.new()
    local v1 = vector.new(1, 2)
    local v2 = m1 * v1

    assert(v2 ~= nil)
    assert(v2.x == 1)
    assert(v2.y == 2)
end

function test_scale()
    local m1 = matrix.scale(2)
    local v1 = vector.new(1, 2)
    local v2 = m1 * v1

    assert(v2 ~= nil)
    assert(v2.x == 2)
    assert(v2.y == 4)
end

function test_translate()
    local m1 = matrix.translate(1, 1)
    local v1 = vector.new(1, 2)
    local v2 = m1 * v1

    assert(v2 ~= nil)
    assert(v2.x == 2)
    assert(v2.y == 3)
end

function test_rotate()
    local m1 = matrix.rotate(math.pi)
    local v1 = vector.new(1, 2)
    local v2 = m1 * v1

    assert(v2 ~= nil)
    assert(v2.x == -1)
    assert(v2.y == -2)
end
