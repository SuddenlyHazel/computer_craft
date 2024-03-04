droneInterface = peripheral.find("drone_interface")
playerInterface = peripheral.find("inventoryManager")
chatbox = peripheral.find("chatBox")
peripheral.find("modem", rednet.open)

pretty = require("cc.pretty")

RECHARGE_POINTS = {}

function listenForCommand()
    while true do
        local id, message = rednet.receive("register_point")
        pretty.print(pretty.pretty(message))
        local position = playerInterface.getItemInOffHand().nbt.Pos
        pretty.print(pretty.pretty(position))
    end
end 

function getPressure()
    return drone_interface.getDronePressure()
end

listenForCommand()