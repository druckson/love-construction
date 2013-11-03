local Class = require "lib/hump/class"

local Messaging = Class{
    init = function(self)
        self.outbox = {}
        self.messageCallbacks = {}
    end
}

function Messaging:register(message, callback)
    if not self.messageCallbacks[message] then
        self.messageCallbacks[message] = {}
    end
    table.insert(self.messageCallbacks[message], callback)
end

function Messaging:emit(message, ...)
    local messaging = self
    if self.messageCallbacks[message] then
        table.insert(self.outbox, {
            message = message,
            args = {...}
        })
    end
end

function Messaging:flush()
    while #self.outbox > 0 do
        local item = table.remove(self.outbox, 1)
        for _, callback in pairs(self.messageCallbacks[item.message]) do
            callback(unpack(item.args))
        end
    end
end

return Messaging
