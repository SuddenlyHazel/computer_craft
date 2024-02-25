player_detector = peripheral.find("playerDetector")

if player_detector == nil then
    error("Player Detector not found. Please ensure one is connected.")
end

while true do
    local is_present = player_detector.isPlayersInCubic(20,20,20)
    local is_disabled = redstone.getInput("right")

    if is_disabled then
        print("Disable lever is engaged")
    end

    print("Player in range?", is_present)
    redstone.setOutput("top", is_present and not is_disabled)
    os.sleep(5)
end