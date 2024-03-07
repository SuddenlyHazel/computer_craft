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

local function listenForSignal()
    local event = os.pullEvent("redstone")
    
    local currentInput = redstone.getBundledInput("back")

    if INNER_WORKING or OUTTER_WORKING then
        print("debounce")
    elseif colors.test(currentInput, OUTTER_DOOR_TOGGLE_STATE) then
        toggleOutterDoor()
    elseif colors.test(currentInput, INNER_DOOR_TOGGLE_STATE) then
        toggleInnerDoor()
    end
end

while true do
    listenForSignal()
end
