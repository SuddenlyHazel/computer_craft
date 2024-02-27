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

function runAlarm()
    local event = os.pullEvent("bulkhead_started")
    print(event)
    speaker.playSound(ALARM)
    while true do
        local event = os.pullEvent("bulkhead_stopped", "speaker_audio_empty")
        print(event)
        if event == "speaker_audio_empty" then
            speaker.playSound(ALARM)
        else
            return runAlarm()
        end
    end
end

function drive_bulkhead()
    os.pullEvent("redstone")

    local running = false;

    local is_at_top = rs.testBundledInput(cable_input, topSensor)
    local is_at_bottom = rs.testBundledInput(cable_input, bottomSensor)
    local is_going_up = rs.testBundledInput(cable_input, gearShift)

    if is_at_top and is_going_up then
        os.queueEvent("bulkhead_stopped")
        rs.setBundledOutput(cable_input, clutch)
    elseif is_at_bottom and not is_going_up then
        os.queueEvent("bulkhead_stopped")
        rs.setBundledOutput(cable_input, colors.combine(clutch, gearShift))
    end
end

function listen_for_command()
    print("drive bulkhead_0001")
    local current_output = rs.getBundledOutput(cable_input)

    local id, message = rednet.receive("bulkhead_0001")
    os.queueEvent("bulkhead_started")
    sleep(1)
    rs.setBundledOutput(cable_input, colors.subtract(current_output, clutch))
end

while true do
    parallel.waitForAny(drive_bulkhead, listen_for_command, runAlarm)
end
