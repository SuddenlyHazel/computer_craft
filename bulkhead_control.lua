peripheral.find("modem", rednet.open)

cable_input = "back"

clutch = colors.lightBlue
gearShift = colors.magenta
topSensor = colors.pink
bottomSensor = colors.orange

currentState = nil

function drive_bulkhead()
    os.pullEvent("redstone")

    local is_at_top = rs.testBundledInput(cable_input, topSensor)
    local is_at_bottom = rs.testBundledInput(cable_input, bottomSensor)
    local is_going_up = rs.testBundledInput(cable_input, gearShift)

    if is_at_top and is_going_up then
        rs.setBundledOutput(cable_input, clutch)
    elseif is_at_bottom and not is_going_up then
        rs.setBundledOutput(cable_input, colors.combine(clutch, gearShift))
    end
end

function listen_for_command()
    print("drive bulkhead_0001")
    local current_output = rs.getBundledOutput(cable_input)

    local id, message = rednet.receive("bulkhead_0001")
    rs.setBundledOutput(cable_input, colors.subtract(current_output, clutch))
end

while true do
    if currentState == nil then
        -- we don't know where the door is
    end
    parallel.waitForAny(drive_bulkhead, listen_for_command)
end
