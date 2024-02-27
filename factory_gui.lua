require(".common.log")
local buttons = require(".common.gui.buttons")

attached_monitor = peripheral.find("monitor")
peripheral.find("modem", rednet.open)

-- Check if the monitor was found
if attached_monitor == nil then
    error("Monitor not found. Please ensure a monitor is connected.")
end

function resetMonitorColors(m)
    m.setBackgroundColor(colors.black)
end

resetMonitorColors(attached_monitor)

attached_monitor.clear()

local monitor_size_x, monitor_size_y = attached_monitor.getSize()
local grid_count_x = 10
local grid_count_y = 15

local grid_size_x = monitor_size_x / grid_count_x
local grid_size_y = monitor_size_y / grid_count_y

print(monitor_size_x, monitor_size_y)
print(grid_size_x, grid_size_y)

function textWidth(input_text, m)
    return string.len(input_text) * m.getTextScale()
end

local buttonOne = buttons.drawButton(attached_monitor, 1, 3, colors.blue, colors.white, "toggle bulkhead",
    function()
        rednet.broadcast({}, "bulkhead_0001")
    end)
buttonOne.draw()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    print("The monitor on side " .. side .. " was touched at (" .. x .. ", " .. y .. ")")
    print(buttonOne.hitTest(x, y))
    print(buttonTwo.hitTest(x, y))
end
