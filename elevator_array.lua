---@class RedstoneIntegrator
---@field getInput fun(side: string):boolean
---@field setOutput fun(side: string, powered: boolean)
---@field getOutput fun(side: string):boolean
---@type RedstoneIntegrator[]
---@diagnostic disable-next-line
INTEGRATORS = { peripheral.find("redstoneIntegrator") }

print(("Found N=%s Integrators"):format(#INTEGRATORS))

---comment
---@param integrator RedstoneIntegrator
local function integratorWatcher(integrator)
    ---@diagnostic disable-next-line
    print(("Starting Integrator Listener Loop for %s"):format(peripheral.getName(integrator)))
    local lastState = integrator.getInput("bottom")
    local lastStateAt = os.epoch("utc")

    while true do
        sleep(0.5)
        local now = os.epoch("utc")
        local currentState = integrator.getInput("bottom")
        local currentOutput = integrator.getOutput("front")

        if currentState ~= lastState then
            lastState = currentState
            lastStateAt = now
        end

        if now + 2 > lastStateAt and currentState ~= currentOutput then
            integrator.setOutput("front", currentState)
        end
    end
end

local hdls = {}

for _, integrator in pairs(INTEGRATORS) do
    table.insert(hdls, function()
        integratorWatcher(integrator)
    end)
end

parallel.waitForAll(table.unpack(hdls))
