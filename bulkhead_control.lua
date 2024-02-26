clutch = colors.lightBlue
gear_shift = colors.magenta
top_sensor = colors.pink
bottom_sensor = colors.orange

::start::

while true do
    local event, sender, message, protocol = os.pullEvent("redstone", "rednet_message")

    if protocol ~= nill then
        print("got rednet message")
        goto start
    end 

    print("got event")
    local is_at_top = rs.testBundledInput("right", top_sensor)
    local is_at_bottom = rs.testBundledInput("right", bottom_sensor)

    print(is_at_top, is_at_bottom)

    if is_at_top then
        local output = colors.combine(clutch)
        rs.setBundledOutput("right", clutch)
    elseif is_at_bottom then
        rs.setBundledOutput("right", clutch)
    end
end