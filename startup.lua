local pretty = require "cc.pretty"
local log = require(".common.log")

SETTINGS_KEY = "hazel.computer_craft"
SERVER_NAME_KEY = "hazel.computer_craft.name"
SERVER_PROGRAMS_KEY = "hazel.computer_craft.toRun"
GITHUB_TOKEN = "hazel.github_token"
PROGRAMS_KEY = "hazel.computer_craft.programs"

DEFAULT_SETTING = {
    ["commit_url"] = "https://api.github.com/repos/SuddenlyHazel/computer_craft/commits/main",
    ["repo_url"] = "https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/%s/%s",
    ["last_commit_hash"] = "",
    ["boot_config"] = "boot.json",
    ["boot_program"] = nil,
    ["programs"] = {},
}

function serverName()
    settings.get(SERVER_NAME_KEY)
end

FIRST_CHECK_DONE = false

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
        local startFile = value["startFile"]
        config["programs"][programId] = {
            ["startFile"] = startFile,
        }
    end

    fs.delete("programs")
    fs.copy(programsDir, "programs")
    fs.delete(programsDir)

    -- Download all common files and write them to disk
    local commonDir = string.format("%s_common", hash)
    fs.makeDir(commonDir)
    for _, value in pairs(bootJson["common"]) do
        print(string.format(":: Fetching common lib | %s", value))

        local progFile = getRepoFile(hash, config["repo_url"], value)
        local path = fs.combine("/", commonDir, value)
        local file = fs.open(path, "w")
        file.write(progFile)
        file.close()
    end

    fs.delete("common")
    fs.copy(commonDir, "common")
    fs.delete(commonDir)

    -- Load any requested programs to be run on this pc
    local startupPrograms = bootJson["deployments"]
    local serverName = settings.get(SERVER_NAME_KEY)
    if serverName and startupPrograms[serverName] then
        print("Found requested programs to run on this server")
        config[SERVER_PROGRAMS_KEY] = startupPrograms[serverName]["programs"]
    end
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
    FIRST_CHECK_DONE = true
end

function buildWatchFunction(socket)
    return function()
        local message = socket.receive()
        while message ~= nil do
            message = textutils.unserializeJSON(message)

            if message["HashUpdated"] ~= nil then
                local currentHash = message["HashUpdated"]
                print(string.format("Got updated hash from server %s", currentHash))
                local config = readConfig()
                local lastHash = config["last_commit_hash"]
                updateSystem(config, currentHash, lastHash)
            end

            message = socket.receive()
        end

        printError("Socket Connection Closed!")
    end
end

function runLocalPrograms()
    print(string.format("Server Name %s", serverName()))
    while not FIRST_CHECK_DONE do
        print("waiting for first check to finish..")
        sleep(1)
    end

    print("first check done! Continuing to start programs")

    local config = readConfig()
    local requestedPrograms = config[SERVER_PROGRAMS_KEY]
    print("starting the following..")
    pretty.pretty_print(requestedPrograms)

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
            local path = fs.combine("programs", programMaybe["startFile"])
            if fs.exists(path) then
                print("Packing function for path ", path)
                programs[i] = run_program(path)
            else
                print("File doesn't exist ", path)
            end
        else
            printError(string.format("failed to find programe %s", name))
        end
    end

    parallel.waitForAll(table.unpack(programs))
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
        parallel.waitForAll(watcher, requestFirstData, runLocalPrograms)
    else
        printError("failed to open socket connection!")
    end
    print("restarting main event loop")
end
