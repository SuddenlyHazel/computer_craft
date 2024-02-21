local modem = peripheral.find("modem", rednet.open)
local protocol = "train_station"

local_train_tracking = {}

function printTable(t, indent)
    indent = indent or 0
    for key, value in pairs(t) do
        if type(value) == "table" then
            print(string.rep("  ", indent) .. key .. ":")
            printTable(value, indent + 1)
        else
            print(string.rep("  ", indent) .. key .. ": " .. tostring(value))
        end
    end
end

function track_train(message)
    local now = os.epoch("local") / 1000

    local departed_at = message["depart_at"]
    local train_name = message["train_name"]
    local station_name = message["station_name"]

    if local_train_tracking[station_name] and local_train_tracking[station_name][train_name] then
        local last_time = local_train_tracking[station_name][train_name]["round_trip_time"]

        if now - local_train_tracking[station_name][train_name]["last_update_at"] < 5 then
            print("debounce")
            return
        end -- debounce

        local_train_tracking[station_name][train_name]["last_update_at"] = now
        local_train_tracking[station_name][train_name]["round_trip_time"] = (departed_at - last_time)
    else
        print("first time seeing train")
        if not local_train_tracking[station_name] then
            local_train_tracking[station_name] = {}
        end
        if not local_train_tracking[station_name][train_name] then
            local_train_tracking[station_name][train_name] = {}
            local_train_tracking[station_name][train_name]["last_update_at"] = now
            local_train_tracking[station_name][train_name]["round_trip_time"] = departed_at
        end
    end
end

function log_data_sample(message)
    local data = local_train_tracking[message["station_name"]][message["train_name"]]
    printTable(data)
end

while true do
    local event, message = rednet.receive(protocol)
    print(message["station_name"])
    print(message["train_name"])
    print(message["depart_at"])

    track_train(message)
    log_data_sample(message)
end
