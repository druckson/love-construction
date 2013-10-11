
local Color = {}

function Color.HsvToRgb(h, s, v, a)
    local sixh = h * 6
    local fc = s * v
    local fx = fc * (1 - math.abs((sixh % 2) - 1))
    local c = fc * 255
    local x = fx * 255
    a = a * 255
    if 0 <= sixh and sixh < 1 then
        return {c, x, 0, a}
    elseif 1 <= sixh and sixh < 2 then
        return {x, c, 0, a}
    elseif 2 <= sixh and sixh < 3 then
        return {0, c, x, a}
    elseif 3 <= sixh and sixh < 4 then
        return {0, x, c, a}
    elseif 4 <= sixh and sixh < 5 then
        return {x, 0, c, a}
    elseif 5 <= sixh and sixh < 6 then
        return {c, 0, x, a}
    end
    return {0, 0, 0, 266}
end

return Color
