local drone = require(".common.drone")


droneInterfaces = { peripheral.find("drone_interface", function(name, wrapped)
    wrapped["iName"] = name
    return true
end) }

---@type Drone[]
droneInterfaces = drone.buildFromInterface(table.unpack(droneInterfaces))

playerInterface = peripheral.find("inventoryManager")
playerDetector = peripheral.find("playerDetector")

chatbox = peripheral.find("chatBox")
peripheral.find("modem", rednet.open)

pretty = require("cc.pretty")

POINTS = {
    recharge = {}
}

function listenForRegisterPointCommand()
    while true do
        local id, message = rednet.receive("register_point")
        pretty.print(pretty.pretty(message))
        local position = playerInterface.getItemInOffHand().nbt.Pos
        pretty.print(pretty.pretty(position))
        POINTS[message.type][message.name] = vector.new(position.X, position.Y, position.Z)
    end
end

function listenForGotoCommand()
    while true do
        local id, message = rednet.receive("goto_point")
        pretty.print(pretty.pretty(message))
        local position = playerInterface.getItemInOffHand().nbt.Pos

        local offset = vector.new(0, 1, 0)
        for _, droneInterface in pairs(droneInterfaces) do
            gotoPoint(gpsToVec(position):add(offset), droneInterface)
        end
    end
end

function listenForComeCommand()
    while true do
        local id, message = rednet.receive("come")
        local location = playerDetector.getPlayerPos("zelamity")
        location = vector.new(location.x, location.y, location.z)

        print(("going to player at %s"):format(pretty.render(pretty.pretty(location))))
        local offset = vector.new(0, 2, 0)
        location = location:add(offset)

        local droneCount = #droneInterfaces

        for _, droneInterface in pairs(droneInterfaces) do
            location = location:add(vector.new(1, 0, 0))
            droneInterface:gotoLocation(location)
        end
    end
end

function getPlayerLocation()
    local playerLocation = playerDetector.getPlayerPos("zelamity")
    return vector.new(playerLocation.x, playerLocation.y, playerLocation.z)
end

function listenForAttackCommand()
    while true do
        local id, message = rednet.receive("attack")

        local playerLocation = getPlayerLocation()

        local location = playerDetector.getPlayerPos("zelamity")
        location = vector.new(location.x, location.y, location.z)

        print(("attacking around player at %s"):format(pretty.render(pretty.pretty(location))))

        local cbs = {}

        for _, droneInterface in pairs(droneInterfaces) do
            table.insert(cbs, droneInterface:attack(message, location))
        end

        parallel.waitForAny(table.unpack(cbs))

        -- todo kick of drone cbs and wait for battle to end
    end
end

function listenForToggleAreaCommand()
    while true do
        local id, message = rednet.receive("toggleArea")
        local location = playerDetector.getPlayerPos("zelamity")
        location = vector.new(location.x, location.y, location.z)

        for _, droneInterface in pairs(droneInterfaces) do
            droneInterface:toggleShowArea()
            break
        end
    end
end

function listenForStandbyCommand()
    while true do
        local id, message = rednet.receive("standby")
        local location = playerDetector.getPlayerPos("zelamity")
        location = vector.new(location.x, location.y, location.z)

        for _, droneInterface in pairs(droneInterfaces) do
            droneInterface:standby()
        end
    end
end

function listenForRechargeCommand()
    while true do
        local id, message = rednet.receive("recharge")
        pretty.print(pretty.pretty(message))
        goToChargePoint()
    end
end

function gpsToVec(gpsVec)
    return vector.new(gpsVec.X, gpsVec.Y, gpsVec.Z)
end

function getPressure(droneInterface)
    return droneInterface.getDronePressure()
end

function goToChargePoint()
    for _, droneInterface in pairs(droneInterfaces) do
        local currentPos = droneInterface.getDronePositionVec()
        currentPos = vector.new(currentPos.x, currentPos.y, currentPos.z)
        local closest = 10000000
        local closestName = "None"
        for k, v in pairs(POINTS["recharge"]) do
            local dist = currentPos:sub(v):length()
            if dist < closest then
                closestName = k
                closest = dist
            end
        end
        print(("recharing drone at %s"):format(closestName))
        gotoPoint(POINTS["recharge"][closestName]:add(vector.new(0, 1, 0)), droneInterface)
    end
end

function gotoPoint(v, droneInterface)
    droneInterface.clearArea()
    droneInterface.addArea(v.x, v.y, v.z)
    droneInterface.setAction("goto")
end

parallel.waitForAny(listenForRegisterPointCommand, listenForGotoCommand,
    listenForRechargeCommand, listenForComeCommand, listenForAttackCommand,
    listenForToggleAreaCommand, listenForStandbyCommand)
