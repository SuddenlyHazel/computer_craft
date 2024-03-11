---@class BlockReader
---@field getBlockData fun():table

BLOCK_READER_NAME = "blockReader"

---@class SmeltGroup
---@field inputChest ccTweaked.peripherals.Inventory
---@field outputChest ccTweaked.peripherals.Inventory
---@field smelter table
---@field name string
SmeltGroup = {}

---@param inputChest ccTweaked.peripherals.Inventory
---@param outputChest ccTweaked.peripherals.Inventory
---@param smelter any
---@param name string
---@return SmeltGroup
function SmeltGroup.new(inputChest, outputChest, smelter, name)
    local instance = setmetatable({}, { __index = SmeltGroup })
    instance.inputChest = inputChest
    instance.outputChest = outputChest
    instance.smelter = smelter
    instance.name = name
    return instance
end

---@return string
function SmeltGroup:getInputChestNetworkName()
    return peripheral.getName(self.inputChest)
end

---@return string
function SmeltGroup:getOutputChestNetworkName()
    return peripheral.getName(self.outputChest)
end

---@return string
function SmeltGroup:getSmelterNetworkName()
    return peripheral.getName(self.smelter)
end

local function extractAttached(blockData, idStart, idEnd)
    local devices = {}
    for i = idStart, idEnd, 1 do
        local blockId = ("PeripheralId%s"):format(i)
        blockId = blockData[blockId]
        local blockType = ("PeripheralType%s"):format(i)
        blockType = blockData[blockType]

        if blockId and blockType then
            table.insert(devices, ("%s_%s"):format(blockType, blockId))
            print(("%s %s"):format(blockId, blockType))
        end
    end

    return devices
end

---comment
---@param list string[]
---@param matcher string
---@return unknown
local function findInList(list, matcher)
    for _, v in pairs(list) do
        local l, r = string.find(v, matcher)
        if l ~= nil and r ~= nil then return v end
    end
    return nil
end

---comment
---@param readers BlockReader[]
---@return SmeltGroup[]
local function buildSmeltGroups(readers, inputChestMatcher, outputChestMatcher, smelterMatcher)
    ---@type BlockReader[]
    local groups = {}

    for _, reader in pairs(readers) do
        local data = reader.getBlockData()
        local extracted = extractAttached(data, 0, 10)
        if extracted then
            local inputChestMaybe = findInList(extracted, inputChestMatcher)
            local outputChestMaybe = findInList(extracted, outputChestMatcher)
            local smelterMaybe = findInList(extracted, smelterMatcher)
            print(("%s %s %s "):format(inputChestMaybe, outputChestMaybe, smelterMaybe))
            if inputChestMaybe and outputChestMaybe and smelterMaybe then
                table.insert(groups, SmeltGroup.new(
                    peripheral.wrap(inputChestMaybe), ---@diagnostic disable-line
                    peripheral.wrap(outputChestMaybe), ---@diagnostic disable-line
                    peripheral.wrap(smelterMaybe), ---@diagnostic disable-line
                    "None"
                ))
            end
        end
    end
    return groups
end

return { extractAttached = extractAttached, SmeltGroup = SmeltGroup, buildSmeltGroups = buildSmeltGroups }
