local Messaging = require "../utils/messaging"

describe("Messaging tests", function()
    it("single message type", function()
        local m = Messaging()
        m:register("test_message", function()
            assert(true)
        end)
        m:emit("test_message")
        m:flush()
    end)

    it("two message types", function()
        local m = Messaging()
        m:register("test_message_1", function()
            assert(false)
        end)
        m:register("test_message_2", function()
            assert(true)
        end)
        m:emit("test_message_2")
        m:flush()
    end)

    it("single message with single argument", function()
        local m = Messaging()
        local o = {}
        m:register("test_message", function(value)
            assert(value == o)
        end)
        m:emit("test_message", o)
        m:flush()
    end)

    it("single message with multiple argument", function()
        local m = Messaging()
        m:register("test_message", function(v1, v2, v3)
            assert(v1 == 1)
            assert(v2 == 2)
            assert(v3 == 3)
        end)
        m:emit("test_message", 1, 2, 3)
        m:flush()
    end)
end)
