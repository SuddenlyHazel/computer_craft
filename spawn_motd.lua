local monitor = peripheral.find("monitor")
monitor.setCursorPos(1, 1)
local resp = http.get("https://github.com/SuddenlyHazel/computer_craft/blob/main/motd.json")

local body = resp.readAll();
body = textutils.unserialiseJSON(body);

for key, value in pairs(myTable) do
  print(key, value)
end