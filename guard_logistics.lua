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
        droneInterface.clearArea()
        droneInterface.addArea(position.X, position.Y+1, position.Z)
        droneInterface.setAction("goto")
    end
end

function getPressure()
    return drone_interface.getDronePressure()
end

function goToChargePoint()
    local currentPos = droneInterface.getDronePositionVec()
end
listenForRegisterPointCommand()