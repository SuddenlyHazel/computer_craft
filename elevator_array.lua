INTEGRATORS = { peripheral.find("redstoneIntegrator") }

print(("Found N=%s Integrators"):format(#INTEGRATORS))

function redstoneListener()
    local event, output = os.pullEvent("redstone")
end

while true do
    print(redstoneListener())
end
