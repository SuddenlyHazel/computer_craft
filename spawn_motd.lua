attached_monitor = peripheral.find("monitor")
-- Check if the monitor was found
if attached_monitor == nil then
    error("Monitor not found. Please ensure a monitor is connected.")
end

while true do
    local now = os.epoch("local") / 1000;
    print("refreshing motd", now)

    local resp = http.get("https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/main/motd.json")
    local body = resp.readAll();
    resp.close()
    
    body = textutils.unserialiseJSON(body);

    attached_monitor.clear()
    local n = 1
    for key, value in pairs(body) do
        attached_monitor.setCursorPos(1, n)
        attached_monitor.write(value)
        n = n + 1
    end
    -- sleep for 30 seconds 
    os.sleep(30)
end
