clutch = colors.lightBlue
gear_shift = colors.magenta
top_sensor = colors.pink
bottom_sensor = colors.orange

while true do
    os.pullEvent("redstone")
    print(rs.testBundledInput("right", top_sensor))
end