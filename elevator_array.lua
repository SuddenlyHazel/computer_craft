INTEGRATORS = { peripheral.find("redstoneIntegrator") }


function redstoneListener()
    local event, output = os.pullEvent("redstone")
end

while true do
    print(redstoneListener())
end