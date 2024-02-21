local modem = peripheral.find("modem", rednet.open)
local protocol = "train_station"

while true do
    local event, message = rednet.receive(protocol)
    print(message["station_name"])
    print(message["train_name"])
    print(message["depart_at"])
end