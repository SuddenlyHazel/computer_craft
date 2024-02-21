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
      rednet.broadcast(message, "base_station")
    elseif redstone.getInput("right") then
      message["name"] = "base_train_b"
      rednet.broadcast("train_2", "base_station")
      print("train_2")
    end
  end
