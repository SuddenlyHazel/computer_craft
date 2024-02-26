peripheral.find("modem", rednet.open)

clutch = colors.lightBlue
gear_shift = colors.magenta
top_sensor = colors.pink
bottom_sensor = colors.orange

function drive_bulkhead()
        print("drive bulkhead_0001")
       os.pullEvent("redstone")

        local is_at_top = rs.testBundledInput("right", top_sensor)
        local is_at_bottom = rs.testBundledInput("right", bottom_sensor)
        local is_going_up = rs.testBundledInput("right", gear_shift)

        print(is_at_top, is_at_bottom)

        if is_at_top and is_going_up then
            local output = colors.combine(colors.subtract(clutch, gear_shift))
            rs.setBundledOutput("right", clutch)
        elseif is_at_bottom and not is_going_up then
            rs.setBundledOutput("right", colors.combine(clutch, gear_shift))
        end
end

function listen_for_command()
    print("drive bulkhead_0001")
    local current_output = rs.getBundledOutput("right")

    local is_at_top = rs.testBundledInput("right", top_sensor)

    local id, message = rednet.receive("bulkhead_0001")
    rs.setBundledOutput("right", colors.subtract(current_output, clutch))
end

while true do
    parallel.waitForAny(drive_bulkhead, listen_for_command)
end