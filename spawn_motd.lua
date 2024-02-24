local monitor = peripheral.find("monitor")
monitor.setCursorPos(1, 1)
local resp = http.get("https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/main/motd.json")
local body = resp.readAll();
body = textutils.unserialiseJSON(body);

local n = 1
for key, value in pairs(body) do
  monitor.setCursorPos(1, n)
  montior.write(value)
  n = n + 1
end