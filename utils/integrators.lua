local function RK(order)
    return function()
        
    end
end

local function RK4(t, dt, state, f)
    local k1 = f(t,             state)
    local k2 = f(t + (0.5*dt),  state + (k1 * 0.5*dt))
    local k3 = f(t + (0.5*dt),  state + (k2 * 0.5*dt))
    local k4 = f(t + dt,        state + (k3 * dt))

    return t + dt, state + ((k1 + ((k2 + k3) * 2) + k4) * dt/6)
end

-- t        - Current time
-- dt       - Time step
-- state    - The current state (e.g. (position, velocity))
-- f        - A function mapping states to their instantaneous derivatives
--
-- Returns (new time, new state)
local function Euler(t, dt, state, f)
    return t + dt, state + (f(t, state) * dt)
end

return {
    Euler = Euler,
    RK4 = RK4,
    RK = RK
}
