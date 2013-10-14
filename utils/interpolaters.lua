
-- lower - the value when t=0
-- upper - the value when t=1
-- t - the interplation value
-- returns a value between lower and upper, using the interpolation value
function lerp(lower, upper, t)
    return ((1-t) * lower) + (t * upper)
end

-- lower - the lower value
-- upper - the upper value
-- value - a value between lower and upper
-- returns a value between 0 and 1
function invlerp(lower, upper, value)
    return (value - lower) / (upper - lower)
end

return {
    lerp = lerp,
    invlerp = invlerp
}
