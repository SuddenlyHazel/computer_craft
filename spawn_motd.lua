local monitor = peripheral.find("monitor")
monitor.setCursorPos(1, 1)
local resp = http.get("https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/main/motd.json")
print(resp)
local body = resp.readAll();
print(body)
body = textutils.unserialiseJSON(body);

for key, value in pairs(body) do
  print(key, value)
end