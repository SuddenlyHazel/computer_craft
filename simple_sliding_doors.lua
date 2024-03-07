INNER_DOOR_TOGGLE_STATE = colors.green
INNER_DOOR = colors.lightBlue

OUTTER_DOOR_TOGGLE_STATE = colors.magenta
OUTTER_DOOR = colors.red


---@alias DoorState
---| '"CLOSED"'
---| '"OUTTER_OPEN"'
---| '"INNER_OPEN"'
---| '"VENTING"'

---comment
---@return DoorState
function getDoorState()
    local currentOutput = redstone.getBundledOutput("back")

    local innerDoorOpen = colors.test(currentOutput, INNER_DOOR)
    local outterDoorOpen = colors.test(currentOutput, OUTTER_DOOR)

    if not innerDoorOpen and not outterDoorOpen then
        return "CLOSED"
    elseif innerDoorOpen then
        return "OUTTER_OPEN"
    elseif outterDoorOpen then
        return "INNER_OPEN"
    end

    return "VENTING"
end

local function toggleInnerDoor()
    local currentState = redstone.getBundledOutput("back")

    -- Ensure Outter door is closed
    if colors.test(currentState, OUTTER_DOOR) then
        currentState = colors.subtract(currentState, OUTTER_DOOR)
        redstone.setBundledOutput("back", currentState)
        os.sleep(3)
    end

    if colors.test(currentState, INNER_DOOR) then
        redstone.setBundledOutput("back", colors.subtract(currentState, INNER_DOOR))
    else
        redstone.setBundledOutput("back", colors.combine(currentState, INNER_DOOR))
    end
    
    os.sleep(3)
end

local function toggleOutterDoor()
    local currentState = redstone.getBundledOutput("back")

    -- Ensure Inner door is closed
    if colors.test(currentState, INNER_DOOR) then
        currentState = colors.subtract(currentState, INNER_DOOR)
        redstone.setBundledOutput("back", currentState)
        os.sleep(3)
    end

    redstone.setBundledOutput("back", colors.combine(currentState, OUTTER_DOOR))
    os.sleep(3)
end

local function listenForSignal()
    local event = os.pullEvent("redstone")
    local currentInput = redstone.getBundledInput("back")

    if colors.test(currentInput, OUTTER_DOOR_TOGGLE_STATE) then
        toggleOutterDoor()
    elseif colors.test(currentInput, INNER_DOOR_TOGGLE_STATE) then
        toggleInnerDoor()
    end
end

while true do
    listenForSignal()
end
