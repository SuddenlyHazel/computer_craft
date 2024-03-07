INNER_DOOR_TOGGLE_STATE = colors.green
INNER_DOOR = colors.lightBlue

OUTTER_DOOR_TOGGLE_STATE = colors.magenta
OUTTER_DOOR = colors.red

OUTTER_WORKING = false
INNER_WORKING = false

local function toggleInnerDoor()
    INNER_WORKING = true
    local currentState = redstone.getBundledOutput("back")

    -- Ensure Outter door is closed
    if colors.test(currentState, OUTTER_DOOR) then
        currentState = colors.subtract(currentState, OUTTER_DOOR)
        redstone.setBundledOutput("back", currentState)
        os.sleep(4)
    end

    if colors.test(currentState, INNER_DOOR) then
        redstone.setBundledOutput("back", colors.subtract(currentState, INNER_DOOR))
    else
        redstone.setBundledOutput("back", colors.combine(currentState, INNER_DOOR))
    end

    os.sleep(4)
    INNER_WORKING = false
end

local function toggleOutterDoor()
    OUTTER_WORKING = true
    local currentState = redstone.getBundledOutput("back")

    -- Ensure Inner door is closed
    if colors.test(currentState, INNER_DOOR) then
        currentState = colors.subtract(currentState, INNER_DOOR)
        redstone.setBundledOutput("back", currentState)
        os.sleep(4)
    end

    if colors.test(currentState, OUTTER_DOOR) then
        redstone.setBundledOutput("back", colors.subtract(currentState, OUTTER_DOOR))
    else
        redstone.setBundledOutput("back", colors.combine(currentState, OUTTER_DOOR))
    end
    os.sleep(4)
    OUTTER_WORKING = false
end

local function buttonListener()
    local outter_door_last_at = os.epoch("utc")
    local inner_door_last_at = os.epoch("utc")

    while true do
        local _ = os.pullEvent("redstone")
        print("got redstone!")

        local currentInput = redstone.getBundledInput("back")
        local now = os.epoch("utc")

        if INNER_WORKING or OUTTER_WORKING then
            print("already working")
        elseif colors.test(currentInput, OUTTER_DOOR_TOGGLE_STATE) and now + 3 > outter_door_last_at then
            outter_door_last_at = now
            os.queueEvent("door_cmd", "outter_door")
            print("outter_door")
        elseif colors.test(currentInput, INNER_DOOR_TOGGLE_STATE) and now + 3 > inner_door_last_at then
            inner_door_last_at = now
            os.queueEvent("door_cmd", "inner_door")
            print("inner_door")
        else
            print("ignoring signal..")
        end
    end
end

local function listenForSignal()
    while true do
        local _, value = os.pullEvent("door_cmd")

        if INNER_WORKING or OUTTER_WORKING then
            print("debounce")
        elseif value == "outter_door" then
            toggleOutterDoor()
        elseif value == "inner_door" then
            toggleInnerDoor()
        end
    end
end

while true do
    parallel.waitForAny(listenForSignal, buttonListener)
end
