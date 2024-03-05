pretty = require("cc.pretty")

---@alias DroneActions
---| '"entity_attack"'
---| '"dig"'
---| '"harvest"'
---| '"place"'
---| '"block_right_click"'
---| '"entity_right_click"'
---| '"pickup_item"'
---| '"drop_item"'
---| '"void_item"'
---| '"void_liquid"'
---| '"inventory_export"'
---| '"inventory_import"'
---| '"liquid_export"'
---| '"liquid_import"'
---| '"entity_export"'
---| '"entity_import"'
---| '"rf_import"'
---| '"rf_export"'
---| '"goto"'
---| '"teleport"'
---| '"emit_redstone"'
---| '"rename"'
---| '"suicide"'
---| '"crafting"'
---| '"standby"'
---| '"logistics"'
---| '"edit_sign"'
---| '"condition_redstone"'
---| '"condition_light"'
---| '"condition_item_inventory"'
---| '"condition_block"'
---| '"condition_liquid_inventory"'
---| '"condition_pressure"'
---| '"drone_condition_item"'
---| '"drone_condition_liquid"'
---| '"drone_condition_entity"'
---| '"drone_condition_pressure"'
---| '"drone_condition_upgrades"'
---| '"condition_rf"'
---| '"drone_condition_rf"'
---| '"computer_control"'



---@class DroneInterface
---@field isConnectedToDrone fun():boolean @Check is there is a drone currently connected to the interface
---@field clearArea fun() @Che
---@field addArea fun(x : number, y : number, z : number) | fun(x : number, y : number, z : number, x1 : number, y1 : number, z1 : number, areaType : string)
---@field setAction fun(action : DroneActions)
---@field getDroneName fun():string
---@field setRenameString fun(name : string)
---@field getDronePressure fun():number
---@field showArea fun()
---@field hideArea fun()
---@field clearWhitelistText fun()
---@field addWhitelistText fun(t : string)
---@field abortAction fun()
---@field setCheckLineOfSight fun(v : boolean)

---@class Drone
---@field name string
---@field droneInterface DroneInterface
---@field isShowingArea boolean
---@field interfaceName string
Drone = {}

Drone.methodMetadata = {}

---@class LocationSource
---@field next fun(): ccTweaked.Vector
LocationSource = {}

---@param next fun(): ccTweaked.Vector
---@return LocationSource
function LocationSource:new(next)
    local instance = setmetatable({}, { __index = LocationSource })
    instance.next = next
    return instance
end

---@return ccTweaked.Vector
function LocationSource:location()
    return self.next()
end

---@return Drone[]
local function buildFromInterface(...)
    local args = { ... }
    local output = {}
    for _, v in pairs(args) do
        table.insert(output, Drone:new(v["iName"], v))
    end
    pretty.print(pretty.pretty(output))
    return output
end

---comment
---@param name string
---@param droneInterface DroneInterface
---@return Drone
function Drone:new(name, droneInterface)
    local instance = setmetatable({}, { __index = Drone })
    instance.name = name
    instance.droneInterface = droneInterface
    instance.isShowingArea = false

    ---@diagnostic disable-next-line
    instance.interfaceName = peripheral.getName(droneInterface)
    print(("init drone with interface %s"):format(instance.name))
    return instance
end

---comment
---@param p ccTweaked.Vector
function Drone:gotoLocation(p)
    if not self:isConnected() then
        print("not connected", self:isConnected())
        return
    end
    self.droneInterface.clearArea()
    self.droneInterface.addArea(p.x, p.y, p.z)
    self.droneInterface.setAction("goto")
end

---comment
---@param p LocationSource
---@param max_distance number
function Drone:follow(p, max_distance)
    if not self:isConnected() then
        print("not connected", self:isConnected())
        return
    end
    local currentLocation = p.next()
end

--- func set the name of the connected drone
---@param name string
function Drone:setName(name)
    if not self:isConnected() then
        print("not connected", self:isConnected())
        return
    end
    self.droneInterface.setRenameString(name)
    self.droneInterface.setAction("rename")
end

---comment
---@return string | nil
function Drone:getName()
    if not self:isConnected() then
        print("not connected", self:isConnected())
        return nil
    end
    return self.droneInterface.getDroneName()
end

Drone.methodMetadata["gotoLocation"] = { _dronePrecheck = true }

--- func get the pressure of the connected drone
---@return number | nil
function Drone:getPressure()
    if not self:isConnected() then return nil end
    return self.droneInterface.getDronePressure()
end

Drone.methodMetadata["getPressure"] = { _dronePrecheck = true }

--- func Put the connected drone into standby mode
function Drone:standby()
    if not self:isConnected() then return end
    print("drone entering standby")
    self.droneInterface.clearArea()
    self.droneInterface.clearWhitelistText()
    self.droneInterface.setAction("standby")
end

Drone.methodMetadata["standby"] = { _dronePrecheck = true }

---@return boolean
function Drone:isConnected()
    return self.droneInterface.isConnectedToDrone()
end

--- func desc toggle the connected drone to show it's set area
function Drone:toggleShowArea()
    if not self:isConnected() then return end
    if self.isShowingArea then
        self.droneInterface.showArea()
    else
        self.droneInterface.hideArea()
    end
end

---comment
---@param allow_filter string
---@param location ccTweaked.Vector
---@return table
function Drone:attack(allow_filter, location)
    ---@diagnostic disable-next-line
    if not self:isConnected() then return end
    
    self.droneInterface.clearArea()
    self.droneInterface.clearWhitelistText()
    self.droneInterface.addWhitelistText(allow_filter)

    local b1 = location:add(vector.new(16, -16, 16))
    local b2 = location:add(vector.new(-16, 16, -16))

    self.droneInterface.addArea(b1.x, b1.y, b1.z, b2.x, b2.y, b2.z, "filled")
    self.droneInterface.setAction("entity_attack")
    self.droneInterface.setCheckLineOfSight(true)

    return {
        stopWatcher = function()
            parallel.waitForAny(
                function()
                    local id, message = rednet.receive("stopAttack")
                    self.droneInterface.clearArea()
                    self.droneInterface.clearWhitelistText()
                    self.droneInterface.abortAction()
                    print(("%s ending attack"):format(self.name))
                end)
        end
    }
end

Drone.methodMetadata["toggleShowArea"] = { _dronePrecheck = true }

return { Drone = Drone, buildFromInterface = buildFromInterface }
