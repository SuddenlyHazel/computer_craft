local modem = peripheral.find("modem", rednet.open)

rednet.host("transit_station","base_station")

while true do
    os.pullEvent("redstone")
    print("A redstone input has changed!")
  end
