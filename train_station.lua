local modem = peripheral.find("modem", rednet.open)

rednet.host("transit_station","base_station")

while true do
    local event = os.pullEvent("redstone")
    print("A redstone input has changed!")
    if event == "left" then
      rednet.broadcast("train_1", "base_station")
    elseif event == "right" then
      rednet.broadcast("train_2", "base_station")
    end
  end
