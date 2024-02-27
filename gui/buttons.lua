local function drawButton(monitor, x, y, color, text_color, button_text, cb)
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
        local isHit = x0 >= x and x0 <= xEnd and y0 == y
        if type(cb) == "function" and isHit then
            cb()
        end
        return isHit
    end

    return { hitTest = hitTest, draw = draw }
end


return { drawButton = drawButton }