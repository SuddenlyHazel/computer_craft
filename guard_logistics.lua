droneInterface = peripheral.find("drone_interface")
playerInterface = peripheral.find("inventoryManager")
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
        gotoPoint(gpsToVec(position))
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

function getPressure()
    return drone_interface.getDronePressure()
end

function goToChargePoint()
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
    gotoPoint(POINTS["recharge"][closestName])
end

function gotoPoint(v)
    droneInterface.clearArea()
    droneInterface.addArea(v.x, v.y, v.z)
    droneInterface.setAction("goto")
end

parallel.waitForAny(listenForRegisterPointCommand, listenForGotoCommand, listenForRechargeCommand)
