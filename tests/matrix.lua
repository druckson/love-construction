local vector = require "../lib/hump/vector"
local matrix = require "../utils/matrix"
local math = require "math"


describe("Test setup", function()
    local m = matrix.new()
    assert(m ~= nil)
end)

describe("Test func", function()
    local m = matrix.new()
    assert(m.getRow ~= nil)
end)

describe("Test value", function()
    local m = matrix.new()
    assert(m[1] ~= nil)
    assert(m[2] ~= nil)
    assert(m[3] ~= nil)
end)

describe("Test identity", function()
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
end)

describe("Test mult", function()
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
end)

describe("Test vector multiplication", function()
    local m1 = matrix.new()
    local v1 = vector.new(1, 2)
    local v2 = m1 * v1

    assert(v2 ~= nil)
    assert(v2.x == 1)
    assert(v2.y == 2)
end)

describe("Test scale", function()
    local m1 = matrix.scale(2)
    local v1 = vector.new(1, 2)
    local v2 = m1 * v1

    assert(v2 ~= nil)
    assert(v2.x == 2)
    assert(v2.y == 4)
end)

describe("Test translate", function()
    local m1 = matrix.translate(1, 1)
    local v1 = vector.new(1, 2)
    local v2 = m1 * v1

    assert(v2 ~= nil)
    assert(v2.x == 2)
    assert(v2.y == 3)
end)

describe("Test rotate", function()
    local m1 = matrix.rotate(math.pi)
    local v1 = vector.new(1, 2)
    local v2 = m1 * v1

    print(v2)
    assert(v2 ~= nil)
    assert(v2.x == -1)
    assert(v2.y == -2)
end)
