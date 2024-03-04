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
    local instance = setmetatable({}, {__index = Drone})
    instance.name = name
    instance.droneInterface = droneInterface
    instance.isShowingArea = false

    print(("init drone with interface %s"):format(instance.name))
    return instance
end

function Drone:gotoLocation(p)
    if not self:isConnected() then return end
    self.droneInterface.clearArea()
    self.droneInterface.addArea(p.x, p.y, p.z)
    self.droneInterface.setAction("goto")
end

Drone.methodMetadata["gotoLocation"] = { _dronePrecheck = true }

function Drone:getPressure()
    if not self:isConnected() then return end
    self.droneInterface.getDronePressure()
end

Drone.methodMetadata["getPressure"] = { _dronePrecheck = true }

function Drone:standby()
    if not self:isConnected() then return end
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
    if not self:isConnected() then return end
    if self.isShowingArea then
        self.droneInterface.showArea()
    else
        self.droneInterface.hideArea()
    end
end

Drone.methodMetadata["toggleShowArea"] = { _dronePrecheck = true }

return { Drone = Drone, buildFromInterface = buildFromInterface }
