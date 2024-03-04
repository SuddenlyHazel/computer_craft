droneInterface = peripheral.find("drone_interface")
playerInterface = peripheral.find("inventoryManager")
chatbox = peripheral.find("chatBox")
peripheral.find("modem", rednet.open)

pretty = require("cc.pretty")

function listenForCommand()
    while true do
        local id, message = rednet.receive("register_point")
        pretty.print(pretty.pretty(message))        
    end
end 

function getPressure()
    return drone_interface.getDronePressure()
end

listenForCommand()