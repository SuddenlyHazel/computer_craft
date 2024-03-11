local smelt_controller = require("smelt.smelt_controller")
local smelt_group = require("smelt.smelt_group")

---@diagnostic disable-next-line
local readers = { peripheral.find("blockReader") }
local groups = smelt_group.buildSmeltGroups(readers, "minecraft", "sophis", "elite")


---@type RsBridge
---@diagnostic disable-next-line
local rsBridge = peripheral.find("rsBridge")

if not rsBridge then
    error("No Refined Storage Bridge Found", 1)
end

local controller = smelt_controller.SmeltController.new(groups, rsBridge)

