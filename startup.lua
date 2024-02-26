local pretty = require "cc.pretty"

SETTINGS_KEY = "hazel.computer_craft"


DEFAULT_SETTING = {
    ["commit_url"] = "https://api.github.com/repos/SuddenlyHazel/computer_craft/commits/main",
    ["repo_url"] = "https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/%s/%s",
    ["last_commit_hash"] = "",
    ["boot_config"] = "boot.json",
    ["boot_program"] = nil,
}

function getHash(url)
    local resp = http.get(url)
    local body = resp.readAll()
    resp.close()
    body = textutils.unserialiseJSON(body)
    return body["sha"]
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

    return defaultOrExisting
end

function getRepoFile(hash, filename)
end

function readBootConfig(hash, config)
    local resp = http.get(string.format(config["repo_url"],
        hash, config["boot_config"]), {
        ["Cache-Control"] = "no-store"
    })

    local body = resp.readAll();
    resp.close()
    return textutils.unserialiseJSON(body);
end

local config = readConfig()
local currentHash = getHash(config["commit_url"])
local lastHash = config["last_commit_hash"]

function updateFiles(bootJson)
    local programs = bootJson["programs"]
    for _, value in pairs(programs) do
        pretty.pretty_print(value)
    end
end
if lastHash ~= currentHash then
    print("Repo has been updated")
    print(string.format("last_sha: %s, current_sha: %s", lastHash, currentHash))
    print("Fetching boot.json..")

    local bootJson = readBootConfig(currentHash, config)
    updateFiles(bootJson)
end