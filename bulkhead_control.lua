peripheral.find("modem", rednet.open)
speaker = peripheral.find("speaker")
ALARM = "mekanism:tile.machine.industrial_alarm"

cable_input = "back"

clutch = colors.lightBlue
gearShift = colors.magenta
topSensor = colors.pink
bottomSensor = colors.orange

currentState = nil

IS_RUNNING = false

function playSound()
    while true do
        speaker.playSound(ALARM, 3)
        sleep(1.6)
    end
end

function runAlarm()
    while true do
        local event = os.pullEvent("bulkhead_started")
        parallel.waitForAny(function() os.pullEvent("bulkhead_stopped") end, playSound)
    end
end

function drive_bulkhead()
    while true do
        os.pullEvent("redstone")

        local is_at_top = rs.testBundledInput(cable_input, topSensor)
        local is_at_bottom = rs.testBundledInput(cable_input, bottomSensor)
        local is_going_up = rs.testBundledInput(cable_input, gearShift)

        if is_at_top and is_going_up then
            os.queueEvent("bulkhead_stopped", {})
            rs.setBundledOutput(cable_input, clutch)
        elseif is_at_bottom and not is_going_up then
            os.queueEvent("bulkhead_stopped", {})
            rs.setBundledOutput(cable_input, colors.combine(clutch, gearShift))
        end
    end
end

function listen_for_command()
    while true do
        print("drive bulkhead_0001")
        local id, message = rednet.receive("bulkhead_0001")
        local current_output = rs.getBundledOutput(cable_input)
        os.queueEvent("bulkhead_started", {})
        rs.setBundledOutput(cable_input, colors.subtract(current_output, clutch))
    end
end

while true do
    parallel.waitForAny(drive_bulkhead, listen_for_command, runAlarm)
end
