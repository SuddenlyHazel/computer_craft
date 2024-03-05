---@class MpscChannel
---@field messages any[]
---@field waiting boolean
---@field onMessage fun(message : any)
---@field size number | nil
---@field waitingProducers thread[]
---@field consumer thread
---@field isClosed boolean
MpscChannel = {}
MpscChannel.__index = MpscChannel

---create a new Multiproducer Single Consumer Channel
---@param onMessage fun(message : any)
---@param size? number
---@return table
function MpscChannel.new(onMessage, size)
    local self = setmetatable({}, MpscChannel)

    self.messages = {} -- Queue to store messages
    self.size = size
    self.onMessage = onMessage

    self.consumer = nil  -- The thread of calling consumer
    self.waiting = false -- Indicates if the consumer is waiting for messages
    self.waitingProducers = {}

    self.isClosed = false
    return self
end

---Close the channel notifying producers on new produces and consumers by returning nil
function MpscChannel:close()
    self.isClosed = true

    for _, producer in pairs(self.waitingProducers) do
        coroutine.resume(producer)
    end

    if self.waiting then
        coroutine.resume(self.consumer)
    end
end

---Attempts to send a message yeilding the calling thread if the buffer exceedes the size
---@param message any
---@return "closed" | "ok"
function MpscChannel:send(message)
    ::start::

    if self.isClosed then
        return "closed"
    end

    if self.size and #self.messages >= self.size then
        local caller = coroutine.running()
        table.insert(self.waitingProducers, caller)
        coroutine.yield()
        goto start
    end

    table.insert(self.messages, message)
    if self.waiting then
        -- If the consumer is waiting, resume it
        self.waiting = false
        coroutine.resume(self.consumer)
    end
    return "ok"
end

---wake waiting producers allowing them to send their messages
---@param self MpscChannel
local function wakeProducers(self)
    local availableSlots = self.size and self.size - #self.messages or #self.waitingProducers
    local toWake = math.min(availableSlots, #self.waitingProducers)

    for i = 1, toWake do
        coroutine.resume(table.remove(self.waitingProducers))
    end
end

--- @class SuccessResult
--- @field value any

--- @alias ReceiveResult
---| SuccessResult    # Success case, with a message
---| '"closed"'
---| '"already_consuming"'   # Error case, specifying the error reason

--- Yields until a message is available on the channel, or nil if the channel is closed, or an error if already consuming
---@return ReceiveResult
function MpscChannel:receive()
    if self.consumer then
        return "already_consuming"
    end

    self.consumer = coroutine.running() -- Store the current coroutine

    ::start::

    local message = nil
    if self.isClosed then
        self.consumer = nil
        return "closed"
    elseif #self.messages == 0 then
        self.waiting = true
        wakeProducers(self)
        coroutine.yield() -- Yield if no messages are available
        self.waiting = false
        goto start
    else
        message = table.remove(self.messages, 1) -- Dequeue the message
        self.consumer = nil
        wakeProducers(self)
    end

    return { value = message }
end

return { MpscChannel = MpscChannel }
