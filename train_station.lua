local modem = peripheral.find("modem", rednet.open)

while true do
    local event = os.pullEvent("redstone")
    print("A redstone input has changed!")
    if redstone.getInput("left") then
      rednet.broadcast("train_1", "base_station")
      print("train_1")
    elseif redstone.getInput("right") then
      rednet.broadcast("train_2", "base_station")
      print("train_2")
    end
  end
