local PACK_ID = "speedrun"
local TEAM = "adamantSpeedrun"
local COORDINATOR_PACKAGE_ID = "Speedrun_Modpack"

local MODULE_PACKAGE_IDS = {
    "Balance_Changes",
    "Gameplay_QoL",
    "LiveSplit",
    "QoL",
    "Select_First_Hammer",
    "Surface_Rebalance",
}

local LIB_DIR = "adamant-ModpackLib"
local MODULES_DIR = "Submodules"
local COORDINATOR_DIR = TEAM .. "-" .. COORDINATOR_PACKAGE_ID

local function module(packageId)
    local pluginGuid = TEAM .. "-" .. packageId
    local moduleDir = MODULES_DIR .. "/" .. pluginGuid
    return {
        pluginGuid = pluginGuid,
        moduleSrcDir = moduleDir .. "/src",
        fixturePath = moduleDir .. "/tests/smoke_env.lua",
        expectedPackId = PACK_ID,
        expectedModuleId = packageId,
        moduleId = packageId,
    }
end

local function modules(packageIds)
    local result = {}
    for index, packageId in ipairs(packageIds) do
        result[index] = module(packageId)
    end
    return result
end

local function coordinator(packageIds)
    if #packageIds == 0 then
        return nil
    end
    return {
        pluginGuid = COORDINATOR_DIR,
        srcDir = COORDINATOR_DIR .. "/src",
    }
end

return {
    allowEmpty = true,
    smokeRunnerPath = LIB_DIR .. "/tests/harness/smoke_runner.lua",
    libSrcDir = LIB_DIR .. "/src",
    packId = PACK_ID,
    config = {
        ModEnabled = true,
        DebugMode = false,
        Profiles = {
            {
                Name = "Default",
                Hash = "",
                Tooltip = "",
            },
        },
    },
    coordinator = coordinator(MODULE_PACKAGE_IDS),
    modules = modules(MODULE_PACKAGE_IDS),
}
