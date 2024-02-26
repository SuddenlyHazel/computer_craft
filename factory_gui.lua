attached_monitor = peripheral.find("monitor")

attached_monitor.clear()

-- Check if the monitor was found
if attached_monitor == nil then
    error("Monitor not found. Please ensure a monitor is connected.")
end

local monitor_size_x, monitor_size_y = attached_monitor.getSize()
local grid_count_x = 10
local grid_count_y = 15

local grid_size_x = monitor_size_x / grid_count_x
local grid_size_y = monitor_size_x / grid_count_y

print(monitor_size_x, monitor_size_y)
function drawButton(monitor, x, y, color, button_text)
    term.redirect(monitor)
    paintutils.drawBox(x, y, x+grid_size_x*3, y + grid_count_y*2, color)
    term.redirect(term.native())
end


drawButton(attached_monitor, 1, 1, colors.blue, "hello world")