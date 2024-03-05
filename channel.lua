Channel = {}
Channel.__index = Channel

function Channel.new(consumer_cb)
    local self = setmetatable({}, Channel)
    self.messages = {}  -- Queue to store messages
    self.waiting = false  -- Indicates if the consumer is waiting for messages
    self.consumer_cb = consumer_cb
    self.consumer_handle = coroutine.create(function() self:receive() end)
    coroutine.resume(self.consumer_handle)

    return self
end

function Channel:send(message)
    table.insert(self.messages, message)
    if self.waiting then
        -- If the consumer is waiting, resume it
        coroutine.resume(self.consumer)
    end
end

function Channel:receive()
    self.consumer = coroutine.running()  -- Store the current coroutine
    while true do
        if #self.messages == 0 then
            self.waiting = true
            coroutine.yield()  -- Yield if no messages are available
            self.waiting = false
        else
            local message = table.remove(self.messages, 1)  -- Dequeue the message
            self.consumer_cb(message)
        end
    end
end

return {Channel = Channel}
