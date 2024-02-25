player_detector = peripheral.find("playerDetector")

if player_detector == nil then
    error("Player Detector not found. Please ensure one is connected.")
end

while true do
    local is_present = player_detector.isPlayersInCubic(20,20,20)
    print("Player in range?", is_present)
    redstone.setOutput("top", is_present)
    os.sleep(5)
end