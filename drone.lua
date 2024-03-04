---@class Drone
Drone = {}
Drone.__index = Drone -- Set the __index metamethod to the class table itself
Drone._mtIndex = {}
Drone.methodMetadata = {}

function buildFromInterface(...)
    local args = {...}
    local output = {}
    for _, v in pairs(args) do
        table.insert(output, Drone:new(v["iName"], v))
    end
    return output
end

function Drone:new(name, droneInterface)
    local self = setmetatable({}, Drone._mtIndex) -- Create a new table and set its metatable to the class
    self.droneInterface = droneInterface
    self.isShowingArea = false
    self.name = name
    print(("init drone with interface %s"):format(self.name))
    return self
end

function Drone:gotoLocation(p)
    self.droneInterface.clearArea()
    self.droneInterface.addArea(p.x, p.y, p.z)
    self.droneInterface.setAction("goto")
end

Drone.methodMetadata["gotoLocation"] = {_dronePrecheck = true}

function Drone:getPressure()
    self.droneInterface.getDronePressure()
end
Drone.methodMetadata["getPressure"] = {_dronePrecheck = true}

function Drone:standby()
    print("drone entering standby")
    self.droneInterface.clearArea()
    self.droneInterface.clearWhitelistText()
    self.droneInterface.setAction("standby")
end

Drone.methodMetadata["standby"] = {_dronePrecheck = true}

function Drone:isConnected()
    self.droneInterface.isConnectedToDrone()
end

function Drone:toggleShowArea()
    if self.isShowingArea then
        self.droneInterface.showArea()
    else
        self.droneInterface.hideArea()
    end
end

Drone.methodMetadata["toggleShowArea"] = {_dronePrecheck = true}

setmetatable(Drone, {
    __index = function(table, key)
        local value = rawget(Drone, key) -- Attempt to get the method directly from the class
        local metadata = Drone.methodMetadata[key]
        -- Check if the method exists and is tagged
        print(key)
        if type(value) == "function" and metadata and metadata._dronePrecheck then
            return function(self, ...)
                if self:isConnected() then
                    return value(self, ...)
                else
                    print("Drone is not connected!")
                    return nil
                end
            end
        else
            -- Return the original value (could be a method or nil)
            return value
        end
    end
})

return {Drone = Drone, buildFromInterface = buildFromInterface}