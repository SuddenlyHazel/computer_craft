local modem = peripheral.find("modem", rednet.open)
local protocol = "train_station"

local_train_tracking = {}

function track_train(message)
    local now = os.epoch("local") / 1000
    local departed_at = message["depart_at"]

    local data_maybe = local_train_tracking[message["station_name"]][message["train_name"]]
    if data_maybe then
        data_maybe["round_trip_time"] = (departed_at - data_maybe["round_trip_time"]) / 2
    else
        local new = {
        }
        new["round_trip_time"] = departed_at
        local_train_tracking[message["station_name"]][message["train_name"]] = new
    end
end

function log_data_sample(message)
    local data_maybe = local_train_tracking[message["station_name"]][message["train_name"]]
    print(data_maybe["round_trip_time"])
end

while true do
    local event, message = rednet.receive(protocol)
    print(message["station_name"])
    print(message["train_name"])
    print(message["depart_at"])

    track_train(message)
    log_data_sample(message)
end
