require(".common.log")

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
    return string.len(input_text) * m.getTextScale()
end

function drawButton(monitor, x, y, color, text_color, button_text)
    local text_width = textWidth(button_text, monitor)
    local xEnd = x + text_width + 2

    local function draw()
        term.redirect(monitor)
        paintutils.drawFilledBox(x, y, xEnd, y, color)
        resetMonitorColors(monitor)

        monitor.setCursorPos(x + 1, y)
        monitor.setTextColor(text_color)
        monitor.setBackgroundColor(color)
        monitor.write(button_text)

        resetMonitorColors(monitor)

        term.redirect(term.native())
    end

    local function hitTest(x0, y0)
        -- x,y   xEnd, y
        -- x,y   xEnd, yEnd
        return x0 >= x and x0 <= xEnd and y0 == y
    end

    return { hitTest = hitTest, draw = draw }
end

local buttonOne = drawButton(attached_monitor, 1, 3, colors.blue, colors.white, "testing world again")
buttonOne.draw()

local buttonTwo = drawButton(attached_monitor, 1, 4, colors.blue, colors.white, "testing world here")
buttonTwo.draw()


while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    print("The monitor on side " .. side .. " was touched at (" .. x .. ", " .. y .. ")")
    print(buttonOne.hitTest(x, y))
    print(buttonTwo.hitTest(x, y))
end
