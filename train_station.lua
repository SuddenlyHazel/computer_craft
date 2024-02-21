local modem = peripheral.find("modem", rednet.open)

local protocol = "train_station"

local message = {
  train_name = "none",
  depart_at = 0,
  direction = "exit",
  station_name = "base_station"
}

while true do
    local event = os.pullEvent("redstone")
    print("A redstone input has changed!")

    local now = os.epoch("local") / 1000

    message["depart_at"] = now;

    if redstone.getInput("left") then
      message["train_name"] = "train_a"
      print("train a exited station")
    elseif redstone.getInput("right") then
      message["train_name"] = "train_b"
      print("train b exited station")
    end

    rednet.broadcast(message, protocol)
  end
