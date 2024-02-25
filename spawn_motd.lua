attached_monitor = peripheral.find("monitor")

-- Check if the monitor was found
if attached_monitor == nil then
    error("Monitor not found. Please ensure a monitor is connected.")
end

local cache_bust = 0

function get_hash()
    local resp = http.get("https://api.github.com/repos/SuddenlyHazel/computer_craft/branches/main")
    local body = resp.readAll()
    resp.close()
    body = textutils.unserialiseJSON(body)
    return body["sha"]
end

local last_hash = ""

function refresh_monitor(file_hash)
    local resp = http.get(string.format("https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/%s/motd.json?",
        file_hash), {
        ["Cache-Control"] = "no-store"
    })
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
end

while true do
    local now = os.epoch("local") / 1000;
    print("refreshing motd", now)

    local current_hash = get_hash()
    print("current hash is: ", current_hash)

    if current_hash ~= last_hash then
      print("hash has changed!")
        refresh_monitor(current_hash)
    end
    -- sleep for 30 seconds 
    os.sleep(5)
end
