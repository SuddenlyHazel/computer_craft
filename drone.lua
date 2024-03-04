pretty = require("cc.pretty")

---@class Drone
Drone = {}

Drone.methodMetadata = {}

function buildFromInterface(...)
    local args = { ... }
    local output = {}
    for _, v in pairs(args) do
        table.insert(output, Drone:new(v["iName"], v))
    end
    pretty.print(pretty.pretty(output))
    return output
end

function Drone:new(name, droneInterface)
    local instance = setmetatable({}, {
        __index = function(table, key)
            local method = Drone[key]
            -- Check if this method requires a precheck
            if Drone.methodMetadata[key] and Drone.methodMetadata[key]._dronePrecheck then
                -- Return a wrapper function
                return function(...)
                    -- Perform the precheck
                    if droneInterface.isConnectedToDrone() then
                        -- Call the original method if precheck passes
                        method(table, ...)
                    else
                        print("Not connected to drone! Eeek")
                    end
                end
            else
                -- Return the original method if no precheck is required
                return method
            end
        end
    })
    instance.name = name
    instance.droneInterface = droneInterface
    instance.isShowingArea = false

    print(("init drone with interface %s"):format(instance.name))
    return instance
end

function Drone:gotoLocation(p)
    self.droneInterface.clearArea()
    self.droneInterface.addArea(p.x, p.y, p.z)
    self.droneInterface.setAction("goto")
end

Drone.methodMetadata["gotoLocation"] = { _dronePrecheck = true }

function Drone:getPressure()
    self.droneInterface.getDronePressure()
end

Drone.methodMetadata["getPressure"] = { _dronePrecheck = true }

function Drone:standby()
    print("drone entering standby")
    self.droneInterface.clearArea()
    self.droneInterface.clearWhitelistText()
    self.droneInterface.setAction("standby")
end

Drone.methodMetadata["standby"] = { _dronePrecheck = true }

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

Drone.methodMetadata["toggleShowArea"] = { _dronePrecheck = true }

return { Drone = Drone, buildFromInterface = buildFromInterface }
