require "lunit"
local matrix = require "../utils/matrix"

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

function test_mult()
    local m1 = matrix.new()
    local m2 = matrix.new()
    assert(m1 * m2 ~= nil)
end
