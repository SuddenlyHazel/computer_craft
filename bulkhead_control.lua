clutch = colors.lightBlue
gear_shift = colors.magenta
top_sensor = colors.pink
bottom_sensor = colors.orange

while true do
    os.pullEvent("redstone")
    print("got event")
    local is_at_top = rs.testBundledInput("right", top_sensor)
    local is_at_bottom = rs.testBundledInput("right", bottom_sensor)
    print(is_at_top, is_at_bottom)
    if is_at_top then
        rs.setBundledOutput("right", clutch)
    elseif is_at_bottom then
        rs.setBundledOutput("right", clutch)
    end
end