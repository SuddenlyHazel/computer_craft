local modem = peripheral.find("modem", rednet.open)

while true do
    local event, message = rednet.receive("base_station")
    print(event)
    print(message)
end