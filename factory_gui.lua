attached_monitor = peripheral.find("monitor")

-- Check if the monitor was found
if attached_monitor == nil then
    error("Monitor not found. Please ensure a monitor is connected.")
end

local monitor_size_x, monitor_size_y = attached_monitor.getSize()
local comp = term.redirect(attached_monitor)

paintutil.drawFilledBox(1, 1, monitor_size_x/4, monitor_size_y/4, colors.red)

term.restore(comp)


function drawButton(monitor, x, y, color, button_text)
    local old_m = term.redirect(monitor)
    monitor.setCursorPos(x + 2, y + 2)
    monitor.write(button_text)
    local text_end_x, text_end_y = monitor.getCursorPos()
    paintutil.drawFilledBox(x, y, text_end_x + 2, y + 4, color)
    term.restore(old_m)
end 


drawButton(attached_monitor, 1, 1, colors.blue, "hello world")