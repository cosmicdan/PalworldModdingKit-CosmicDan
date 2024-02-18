-- Modified UE4SS 2.5 loader for ServerTools because UE4SS 3.0's loader seems broken on dedicated servers

local UEHelpers = require("UEHelpers")

local VerboseLogging = true

local printOrg = print
local function Log(Message, AlwaysLog)
    if not VerboseLogging and not AlwaysLog then return end
    printOrg(Message)
end

package.path = '.\\Mods\\ModLoaderMod\\?.lua;' .. package.path
package.path = '.\\Mods\\ModLoaderMod\\BPMods\\?.lua;' .. package.path

Mods = {}

local DefualtModConfig = {}
--DefualtModConfig.AssetName = "ModActor_C"
DefualtModConfig.AssetName = "ServerToolsActor_C"
--DefualtModConfig.AssetNameAsFName = FName("ModActor_C")
DefualtModConfig.AssetNameAsFName = FName("ServerToolsActor_C")

-- Explodes a string by a delimiter into a table
local function Explode(String, Delimiter)
    local ExplodedString = {}
    local Iterator = 1
    local DelimiterFrom, DelimiterTo = string.find(String, Delimiter, Iterator)

    while DelimiterTo do
        table.insert(ExplodedString, string.sub(String, Iterator, DelimiterFrom-1))
        Iterator = DelimiterTo + 1
        DelimiterFrom, DelimiterTo = string.find(String, Delimiter, Iterator)
    end
    table.insert(ExplodedString, string.sub(String, Iterator))

    return ExplodedString
end

local function LoadModConfigs()
    -- Load configurations for mods.
    local Dirs = IterateGameDirectories();
    if not Dirs then
        error("[BPModLoader] UE4SS does not support loading mods for this game.")
    end
    local LogicModsDir = Dirs.Game.Content.Paks.LogicMods
    if not Dirs then error("[BPModLoader] IterateGameDirectories failed, cannot load BP mod configurations.") end
    if not LogicModsDir then
        CreateLogicModsDirectory();
        Dirs = IterateGameDirectories();
        LogicModsDir = Dirs.Game.Content.Paks.LogicMods
        if not LogicModsDir then error("[BPModLoader] Unable to find or create Content/Paks/LogicMods directory. Try creating manually.") end
    end
    for ModDirectoryName,ModDirectory in pairs(LogicModsDir) do
        --Log(string.format("Mod: %s\n", ModDirectoryName))
        for _,ModFile in pairs(ModDirectory.__files) do
            --Log(string.format("    ModFile: %s\n", ModFile.__name))
            if ModFile.__name == "config.lua" then
                dofile(ModFile.__absolute_path)
                if type(Mods[ModDirectoryName]) ~= "table" then break end
                if not Mods[ModDirectoryName].AssetName then break end
                Mods[ModDirectoryName].AssetNameAsFName = FName(Mods[ModDirectoryName].AssetName)
                break
            end
        end
    end

    -- Load a default configuration for mods that didn't have their own configuration.
    for _, ModFile in pairs(LogicModsDir.__files) do
        local ModName = ModFile.__name
        local ModNameNoExtension = ModName:match("(.+)%..+$")
        local FileExtension = ModName:match("^.+(%..+)$");
        if FileExtension == ".pak" and not Mods[ModNameNoExtension] then
            --Log("--------------\n")
            --Log(string.format("ModFile: '%s'\n", ModFile.__name))
            --Log(string.format("ModNameNoExtension: '%s'\n", ModNameNoExtension))
            --Log(string.format("FileExtension: %s\n", FileExtension))
            Mods[ModNameNoExtension] = {}
            Mods[ModNameNoExtension].AssetName = DefualtModConfig.AssetName
            Mods[ModNameNoExtension].AssetNameAsFName = DefualtModConfig.AssetNameAsFName
            --Mods[ModNameNoExtension].AssetPath = string.format("/Game/Mods/%s/ModActor", ModNameNoExtension)
            Mods[ModNameNoExtension].AssetPath = string.format("/Game/Mods/%s/ServerToolsActor", ModNameNoExtension)
        end
    end
end

LoadModConfigs()

--[[
for k,v in pairs(Mods) do
    Log(string.format("%s == %s\n", k, v))
    if type(v) == "table" then
        for k2,v2 in pairs(v) do
            Log(string.format("    %s == %s\n", k2, v2))
        end
    end
end
]]--

local AssetRegistryHelpers = nil
local AssetRegistry = nil

local function LoadMod(World)
    local AssetData = {
        ["PackageName"] = FName("/Game/Mods/ServerTools/ServerToolsActor", EFindName.FNAME_Add),
        ["AssetName"] = FName("ServerToolsActor_C", EFindName.FNAME_Add),
    }
    
    ExecuteInGameThread(function()
        local ModClass = AssetRegistryHelpers:GetAsset(AssetData)
        if not ModClass:IsValid() then
            error("Main ServerTools class not found. Missing ServerTools.pak?")    
        end

        if not World:IsValid() then error("World is not valid") end
        --Log(string.format("~~~~ WorldClass = '%s'\n", World:GetFullName()))
        --Log(string.format("~~~~ GameModeClass = '%s'\n", GameMode:GetFullName()))

        local Actor = World:SpawnActor(ModClass, {}, {})
        if not Actor:IsValid() then
            Log(string.format("Actor for mod '%s' is not valid\n", ModName))
        else
            Log(string.format("Actor: %s\n", Actor:GetFullName()))
            local PreBeginPlay = Actor.PreBeginPlay
            if PreBeginPlay:IsValid() then
                Log(string.format("Executing 'PreBeginPlay' for mod '%s'\n", Actor:GetFullName()))
                PreBeginPlay()
            else
                Log("PreBeginPlay not valid\n")
            end
        end
    end)
end


local function CacheAssetRegistry()
    if AssetRegistryHelpers and AssetRegistry then return end

    AssetRegistryHelpers = StaticFindObject("/Script/AssetRegistry.Default__AssetRegistryHelpers")
    if not AssetRegistryHelpers:IsValid() then print("AssetRegistryHelpers is not valid\n") end

    if AssetRegistryHelpers then
        AssetRegistry = AssetRegistryHelpers:GetAssetRegistry()
        if AssetRegistry:IsValid() then return end
    end

    AssetRegistry = StaticFindObject("/Script/AssetRegistry.Default__AssetRegistryImpl")
    if AssetRegistry:IsValid() then return end

    error("AssetRegistry is not valid\n")
end

local loadWorldLoops = 0
LoopAsync(10, function()
    if loadWorldLoops >= 3000 then -- wait 30 seconds max
        print("World has still not loaded after 30 seconds... aborting.")
        return true
    end	
        
    local World = StaticFindObject("/Game/Pal/Maps/MainWorld_5/PL_MainWorld5.PL_MainWorld5")
    if World:IsValid() then
    	--print("World found! Load mod....")
        --ExecuteWithDelay(1000, function()
        --LoadMods(World)
        CacheAssetRegistry()
        LoadMod(World)
        

        RegisterBeginPlayPostHook(function(ContextParam)
            local Context = ContextParam:get()
            for _,ModConfig in pairs(Mods) do
                if Context:GetClass():GetFName() ~= ModConfig.AssetNameAsFName then return end
                local PostBeginPlay = Context.PostBeginPlay
                if PostBeginPlay:IsValid() then
                    Log(string.format("Executing 'PostBeginPlay' for mod '%s'\n", Context:GetFullName()))
                    PostBeginPlay()
                else
                    Log("PostBeginPlay not valid\n")
                end
            end
        end)
        --end)
        return true
    end
   
    loadWorldLoops = loadWorldLoops + 1
    return false
end)
