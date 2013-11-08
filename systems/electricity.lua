local Class = require "lib/hump/class"

local Node = Class{
    init = function(self, entity, data)
        self.entity = entity

        self.inputCapacity = data.inputCapacity or 0
        self.outputCapacity = data.outputCapacity or 0

        self.draw = 0
        self.drain = 0

        self.throughput = throughput
        self.peers = {}
    end
}

function Node:potentialOutput()
    return math.min(self.outputCapacity, self.outputPower)
end

function Node:addPower(p)
    self.draw = 1
end

function Node:removePower(p)
    self.drain = p
end

function Node:link(other)
    table.insert(self.peers, other)
    table.insert(other.peers, self)
end

local t = 0
function Node:update(dt)
    -- TEST
    t = t + dt*5
    self.draw = (math.sin(t) + 1)/2
end

local Circuit = Class{
    init = function(self)
        self.nodes = {}
    end
}

function Circuit:update(dt)
    -- Calculate the input and output currents for each node
    --
    -- Desired properties:
    --  - Multiple power sources increase the capacity of the network
    --  - If the circuit isn't supplied enough power, power sinks will receive less than they ask for
    --  - If the circuit is supplied more than enough power to supply the power sinks, the sources will
    --    only be required to supply the amount of power necessary to fill this need.
    
    local desiredInput = 0
    local potentialOutput = 0

    for _, node in pairs(self.nodes) do
        desiredInput = desiredInput + node.inputCapacity
        potentialOutput = potentialOutput + node:potentialOutput()
    end

    local totalFlux = math.min(desiredInput, potentialOutput)

    for _, node in pairs(self.nodes) do
        node:addPower(totalFlux * node.inputCapacity / desiredInput)
        node:removePower(totalFlux * node:potentialOutput() / potentialOutput)
    end
end

local Electricity = Class{
    init = function(self)
        self.entities = {}
        self.circuits = {}
    end
}

function Electricity:setup(engine)
    local electricity = self

    -- Generate/update circuits
    engine.messaging:register("connect", function(entity1, entity2)
        if entity1.electricity and 
           entity2.electricity then
            entity1.electricity:link(entity2.electricity)
        end
    end)
end

function Electricity:init_entity(entity, data)
    entity.electricity = Node(entity, data)
    table.insert(self.entities, entity)
end

function Electricity:remove_entity(entity)
    for key, value in pairs(electricity.entities) do
        if value == entity then
            table.remove(electricity.entities, key)
        end
    end
end

function Electricity:update(dt)
    for _, entity in pairs(self.entities) do
        entity.electricity:update(dt)
    end
end

return Electricity
