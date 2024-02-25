attached_monitor = peripheral.find("monitor")
-- Check if the monitor was found
if attached_monitor == nil then
    error("Monitor not found. Please ensure a monitor is connected.")
end

local cache_bust = 0

while true do
    local now = os.epoch("local") / 1000;
    print("refreshing motd", now)
    cache_bust = cache_bust + 10
    local resp = http.get(string.format("https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/main/motd.json?v=%s", cache_bust), {["Cache-Control"] = "no-store"})
    local body = resp.readAll();
    resp.close()
    
    body = textutils.unserialiseJSON(body);

    attached_monitor.clear()

    attached_monitor.setCursorPos(1, 1)
    attached_monitor.write(body["headline"])


    local n = 2
    for _, value in pairs(body["body"]) do
        attached_monitor.setCursorPos(1, n)
        attached_monitor.write(value)
        n = n + 1
    end
    -- sleep for 30 seconds 
    os.sleep(30)
end
