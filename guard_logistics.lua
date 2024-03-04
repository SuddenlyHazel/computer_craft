droneInterface = peripheral.find("drone_interface")
playerInterface = peripheral.find("inventoryManager")
chatbox = peripheral.find("chatBox")
peripheral.find("modem", rednet.open)

pretty = require("cc.pretty")

function listenForCommand()
    while true do
        local id, message = rednet.listen("register_point")
        pretty.print(message)        
    end
end 

function getPressure()
    return drone_interface.getDronePressure()
end

listenForCommand()