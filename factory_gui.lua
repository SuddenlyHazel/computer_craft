attached_monitor = peripheral.find("monitor")

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
    local char_width = 6
    return string.len(input_text) * char_width * m.getTextScale()
end

function drawButton(monitor, x, y, color, text_color, button_text)
    local text_width = textWidth(button_text, monitor)
    print(string.format("text width %s", text_width))
    term.redirect(monitor)
    
    paintutils.drawFilledBox(x, y, x+string.len(button_text), y + (grid_size_y*2), color)
    resetMonitorColors(monitor)

    monitor.setCursorPos(x, y)
    monitor.setTextColor(text_color)
    monitor.setBackgroundColor(color)
    monitor.write(button_text)

    resetMonitorColors(monitor)

    term.redirect(term.native())
end


drawButton(attached_monitor, 1, 1, colors.blue, colors.white, "hello world")