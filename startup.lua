local pretty = require "cc.pretty"

SETTINGS_KEY = "hazel.computer_craft"
PROGRAMS_KEY = "hazel.computer_craft.programs"

DEFAULT_SETTING = {
    ["commit_url"] = "https://api.github.com/repos/SuddenlyHazel/computer_craft/commits/main",
    ["repo_url"] = "https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/%s/%s",
    ["last_commit_hash"] = "",
    ["boot_config"] = "boot.json",
    ["boot_program"] = nil,
    ["programs"] = {},
}

function getGithubToken()
    settings.get(GITHUB_TOKEN)
end

function readConfig()
    local settingsExists = settings.load()

    local defaultOrExisting = settings.get(SETTINGS_KEY, DEFAULT_SETTING)

    if not settingsExists then
        print("persisting settings for the first time..")
        settings.save()
    else
        print("found stored settings!")
    end

    migrateConfig(defaultOrExisting)
    settings.save()
    return defaultOrExisting
end

function saveConfig(config)
    print("Persisting updated config")
    settings.set(SETTINGS_KEY, config)
    settings.save()
end

function getRepoFile(hash, repoUrl, filename)
    local resp = http.get(string.format(repoUrl,
        hash, filename), {
        ["Cache-Control"] = "no-store"
    })

    local body = resp.readAll();
    resp.close()
    return body
end

function readBootConfig(hash, config)
    return textutils.unserialiseJSON(getRepoFile(hash, config["repo_url"], config["boot_config"]));
end

function updateFiles(hash, bootJson, config)
    -- Download all startupPrograms and write them to disk
    local startupPrograms = bootJson["startup"]
    fs.makeDir(hash)
    for _, value in pairs(startupPrograms) do
        print(string.format(":: Fetching Startup program | %s", value["id"]))
        for _, filename in pairs(value["files"]) do
            print(string.format("       :: fetching file %s", filename))
            local progFile = getRepoFile(hash, config["repo_url"], filename)
            local path = fs.combine("/", hash, filename)
            local file = fs.open(path, "w")
            file.write(progFile)
            file.close()
        end
    end

    fs.delete("startup")
    fs.delete("startup.lua")
    fs.copy(hash, "startup")
    fs.delete(hash)

    -- Download all program files and write them to disk
    local programsDir = string.format("%s_programs", hash)
    fs.makeDir(programsDir)
    config["programs"] = {}
    for _, value in pairs(bootJson["programs"]) do
        local programId = value["id"];

        print(string.format(":: Fetching program | %s", programId))

        for _, filename in pairs(value["files"]) do
            print(string.format("       :: fetching file %s", filename))
            local progFile = getRepoFile(hash, config["repo_url"], filename)
            local path = fs.combine("/", programsDir, filename)
            local file = fs.open(path, "w")
            file.write(progFile)
            file.close()
        end
        local startFile = bootJson["startFile"]
        config["programs"][programId] = {
            ["startfile"] = startFile,
        }
    end

    fs.delete("programs")
    fs.copy(programsDir, "programs")
    fs.delete(programsDir)
end

function updateSystem(config, currentHash, lastHash)
    if lastHash ~= currentHash then
        pretty.print(pretty.text("Repo has been updated", colors.red))
        print(string.format("last_sha: %s, current_sha: %s", lastHash, currentHash))
        pretty.print(pretty.text("Fetching boot.json..", colors.blue))

        local bootJson = readBootConfig(currentHash, config)
        updateFiles(currentHash, bootJson, config)
        config["last_commit_hash"] = currentHash
        saveConfig(config)
        os.reboot()
    else
        pretty.print(pretty.text("No updates", colors.blue))
    end
end

function buildWatchFunction(socket)
    function watchForRepoChanges()
        while true do
            local message = socket.receive()

            if message == nil then
                break
            end

            local message = textutils.unserializeJSON(message)

            if message["HashUpdated"] ~= nil then
                local currentHash = message["HashUpdated"]
                print(string.format("Got updated hash from server %s", currentHash))
                local config = readConfig()
                local lastHash = config["last_commit_hash"]
                updateSystem(config, currentHash, lastHash)
            end
        end

        print("Socket Connection Closed!")
    end

    return watchForRepoChanges
end

function readRequestedProgramsList()
    settings.load("PROGRAMS_KEY")
    return settings.get("PROGRAMS_KEY", {})
end

function runLocalPrograms()
    local config = readConfig()
    local requestedPrograms = readRequestedProgramsList()

    function run_program(progPath)
        return function() 
            local status, result = pcall(shell.run, progPath)
            if not status then
                print(string.format("Program %s failed Error %s", progPath, result))
            end
        end
    end

    local programs = {}
    for i, name in ipairs(requestedPrograms) do
        local programMaybe = config["programs"][name]
        if programMaybe ~= nil then
            programs[i] =
            print("attempting to start ", name)
        end
    end
end

while true do
    print("attempting to open websocket connection..")
    local socket = http.websocket("wss://computer-craft-bridge.hazel.ooo/ws")

    function requestFirstData()
        socket.send(
            "\"GetCurrentHash\""
        )
    end

    if socket ~= nil then
        local watcher = buildWatchFunction(socket)
        parallel.waitForAll(watcher, requestFirstData)
    else
        print("failed to open socket connection!")
    end
    print("restarting main event loop")
end
