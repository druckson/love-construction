local Electricity = {
    objects = {},
    circuits = {}
}

function Electricity:add(object)
    object.electricity = {
        charge = 0,
        neighbors = {}
    }
    table.insert(self.objects, object)
end

function Electricity:link(o1, o2)
    assert(o1.electricity ~= nil and o2.electricity ~= nil,
           "Link: wrong argument types (electricity expected)")
    table.insert(o1.electricity.neighbors, o2)
    table.insert(o2.electricity.neighbors, o1)
end

function Electricity:unlink(o1, o2)
    assert(o1.electricity ~= nil and o2.electricity ~= nil,
           "Unlink: wrong argument types (electricity expected)")
    table.remove(o1.electricity.neighbors, o2)
    table.remove(o2.electricity.neighbors, o1)
end

function Electricity:update(dt)
    
end

return Electricity
