peripheral.find("modem", function(name, wrapped)
    if wrapped.isWireless() then
       rednet.open() 
    end
end)

if not rednet.isOpen() then
    error("No wireless modem found", 2)
end