peripheral.find("modem", rednet.open)

clutch = colors.lightBlue
gear_shift = colors.magenta
top_sensor = colors.pink
bottom_sensor = colors.orange

function drive_bulkhead()
       os.pullEvent("redstone")

        local is_at_top = rs.testBundledInput("right", top_sensor)
        local is_at_bottom = rs.testBundledInput("right", bottom_sensor)

        print(is_at_top, is_at_bottom)

        if is_at_top then
            local output = colors.combine(clutch)
            rs.setBundledOutput("right", clutch)
        elseif is_at_bottom then
            rs.setBundledOutput("right", clutch)
        end
end

function listen_for_command()
    local id, message = rednet.receive("bulkhead_0001")
    print(id, message)
end

while true do
    parallel.waitForAny(drive_bulkhead, listen_for_command)
end