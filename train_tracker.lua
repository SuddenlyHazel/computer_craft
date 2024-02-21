local modem = peripheral.find("modem", rednet.open)

while true do
    local event = rednet.receive("base_station")
    print(event)
end