local smeltGroup = require(".smelt.smelt_group")
local pretty = require("cc.pretty")

---@class RsBridgeItem
---@field amount number
---@field displayName string
---@field fingerprint string
---@field isCraftable boolean
---@field tags string[]

---@class RsBridge
---@field importItem fun(item: table, direction: string):number
---@field exportItem fun(item: table, direction: string):number
---@field importItemFromPeripheral fun(item: table, container: string):number
---@field exportItemToPeripheral fun(item: table, container: string):number
---@field listItems fun(): RsBridgeItem[]

---@class SmeltController
---@field smelters SmeltGroup[]
---@field refinedStorageController RsBridge
SmeltController = {}


---comment
---@param smelters SmeltGroup[]
---@param refinedStorageController RsBridge
---@return SmeltController
function SmeltController.new(smelters, refinedStorageController)
    local instance = setmetatable({}, { __index = SmeltController })
    instance.smelters = smelters
    instance.refinedStorageController = refinedStorageController
    return instance
end

---comment
---@param matcher string | number
function SmeltController:searchRefinedStorageItemsByName(matcher)
    local items = self.refinedStorageController.listItems()

    ---@type RsBridgeItem[] | table
    local match = {}

    for _, item in pairs(items) do
        local l, r = item.displayName:find(matcher)
        if l ~= nil and r ~= nil then
            table.insert(match, item)
        end
    end

    return table
end

return { SmeltController = SmeltController }