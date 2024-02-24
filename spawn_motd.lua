local monitor = peripheral.find("monitor")
monitor.setCursorPos(1, 1)
local resp = http.get("https://github.com/SuddenlyHazel/computer_craft/blob/main/motd.json")
print(resp)
local body = resp.readAll();
print(body)
body = textutils.unserialiseJSON(body);

for key, value in pairs(body) do
  print(key, value)
end