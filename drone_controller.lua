local pretty = require("cc.pretty")
---@module "computer_craft.drone"
local drone = require(".common.drone")

---@class DronesController
---@field drones Drone[]
---@field disconnectCallbacks fun(Drone)[]
---@field connectedCallbacks fun(Drone)[]
---@field disconnectedInterfaces DroneInterface[]
---@field disconnectedWatchProcess thread
---@field connectedWatchProcess thread

DronesController = {}

DroneCommands = {
    Come = 1,
    Attack = 2,
    Standby = 3,
    ToggleShowArea = 4,
}

---@alias DoneCb function fun():boolean

---@class GotoCommand
---@field pos1 ccTweaked.Vector
---@field pos2? ccTweaked.Vector
---@field areaType? string
---@field doneCb DoneCb

---@class AttackCommand
---@field pos1 ccTweaked.Vector
---@field pos2 ccTweaked.Vector
---@field doneCb DoneCb

---@class StandbyCommand
---@field doneCb DoneCb

---@alias DroneCommands
---| GotoCommand
---| AttackCommand
---| StandbyCommand




---comment
---@param droneController DronesController
local function disconnectWatcher(droneController)
    while true do
        sleep(1)
        for k, drone in ipairs(droneController.drones) do
            if not drone:isConnected() then
                for _, cb in pairs(droneController.disconnectCallbacks) do
                    cb(drone)
                end

                print(("Drone not connected! Removing drone %s from DroneController"):format(
                ---@diagnostic disable-next-line
                    peripheral.getName(drone.droneInterface)
                ))

                table.remove(droneController.drones, k)
                table.insert(droneController.disconnectedInterfaces, drone.droneInterface)
            end
        end
    end
end

---@param droneController DronesController
local function reconnectWatched(droneController)
    while true do
        sleep(1)
        for k, interface in ipairs(droneController.disconnectedInterfaces) do
            if interface.isConnectedToDrone() then
                ---@diagnostic disable-next-line
                print(("! Interface %s has reconnected to a drone"):format(peripheral.getName(interface)))

                for _, cb in pairs(droneController.connectedCallbacks) do
                    cb(drone)
                end
            end
        end
    end
end

---@return DronesController
function DronesController:new(...)
    local args = { ... }

    ---@type DronesController
    local instance = setmetatable({}, { __index = DronesController })
    instance.drones = args

    instance.disconnectedInterfaces = {}

    instance.disconnectCallbacks = {}
    instance.disconnectedWatchProcess = coroutine.create(function(instance)
        disconnectWatcher(instance)
    end)

    instance.connectedCallbacks = {}
    instance.connectedWatchProcess = coroutine.create(function()
        reconnectWatched(instance)
    end)

    coroutine.resume(instance.disconnectedWatchProcess)
    coroutine.resume(instance.connectedWatchProcess)

    return instance
end

---@return DronesController
local function newFromLocalInterfaces()
    ---@diagnostic disable-next-line
    local droneInterfaces = { peripheral.find("drone_interface", function(name, wrapped)
        wrapped["iName"] = name
        return true
    end) }

    droneInterfaces = drone.buildFromInterface(table.unpack(droneInterfaces))
    return DronesController:new(droneInterfaces)
end

return { DronesController = DronesController, newFromLocalInterfaces = newFromLocalInterfaces }
