pretty = require("cc.pretty")

---@class Drone
---@field name string
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

---comment
---@return Drone
function Drone:new(name, droneInterface)
    local instance = setmetatable({}, { __index = Drone })
    instance.name = name
    instance.droneInterface = droneInterface
    instance.isShowingArea = false

    print(("init drone with interface %s"):format(instance.name))
    return instance
end

function Drone:gotoLocation(p)
    if not self:isConnected() then
        print("not connected", self:isConnected())
        return
    end
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
    return self.droneInterface.isConnectedToDrone()
end

function Drone:toggleShowArea()
    if not self:isConnected() then return end
    if self.isShowingArea then
        self.droneInterface.showArea()
    else
        self.droneInterface.hideArea()
    end
end

function Drone:attack(allow_filter, location)
    self.droneInterface.clearArea()
    self.droneInterface.clearWhitelistText()
    self.droneInterface.addWhitelistText(allow_filter)

    local b1 = location:add(vector.new(16, -16, 16))
    local b2 = location:add(vector.new(-16, 16, -16))
    self.droneInterface.addArea(b1.x, b1.y, b1.z, b2.x, b2.y, b2.z, "filled")
    self.droneInterface.setAction("entity_attack")

    return {
        stopWatcher = function()
            parallel.waitForAny(
                function()
                    local id, message = rednet.receive("stopAttack")
                    droneInterface.clearArea()
                    droneInterface.clearWhitelistText()
                    droneInterface.abortAction()
                    print(("%s ending attack"):format(self.name))
                end)
        end
    }
end

Drone.methodMetadata["toggleShowArea"] = { _dronePrecheck = true }

return { Drone = Drone, buildFromInterface = buildFromInterface }
