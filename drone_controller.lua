pretty = require("cc.pretty")
local drone = require(".common.drone")

---@class DronesController
---@field drones Drone[]
DronesController = {}

DroneCommands = {
    Come = 1,
    Attack = 2,
    Standby = 3,
    ToggleShowArea = 4,
}

---@return DronesController
function DronesController:new(...)
    local args = { ... }

    local instance = setmetatable({}, { __index = Drone })
    instance.drones = args
    return instance
end

---@return DronesController
function newFromLocalInterfaces()
    local droneInterfaces = { peripheral.find("drone_interface", function(name, wrapped)
        wrapped["iName"] = name
        return true
    end) }
    droneInterfaces = drone.buildFromInterface(table.unpack(droneInterfaces))
    return DronesController:new(droneInterfaces)
end

return { DronesController = DronesController, newFromLocalInterfaces = newFromLocalInterfaces }
