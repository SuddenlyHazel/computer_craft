attached_monitor = peripheral.find("monitor")

-- Check if the monitor was found
if attached_monitor == nil then
  error("Monitor not found. Please ensure a monitor is connected.")
end

local resp = http.get("https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/main/motd.json")
local body = resp.readAll();
body = textutils.unserialiseJSON(body);

local n = 1
for key, value in pairs(body) do
  attached_monitor.setCursorPos(1,n)
  attached_monitor.write(value)
  n = n + 1
end