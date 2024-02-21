local modem = peripheral.find("modem", rednet.open)

local message = {
  name = "none",
  depart_at = 0,
}

while true do
    local event = os.pullEvent("redstone")
    print("A redstone input has changed!")

    local now = {
      time = os.epoch("local") / 1000
    }
    message["depart_at"] = now;

    if redstone.getInput("left") then
      message["name"] = "base_train_a"
      print("train a exited station")
    elseif redstone.getInput("right") then
      message["name"] = "base_train_b"
      print("train b exited station")
    end

    rednet.broadcast(message, "base_station")
  end
