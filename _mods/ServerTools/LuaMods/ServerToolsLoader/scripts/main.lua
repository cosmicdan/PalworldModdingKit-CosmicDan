--[[
    ServerTools Loader
    
    Bootstraps the main BP as well as some other essentials
    
    Daniel "CosmicDan" Connolly
]]--

local modActorClassName = "ServerToolsActor"

require("servertoolsloader")

-- Credits to Khejanin for this function
local function getServerToolsModActor()
    local modActors = FindAllOf(modActorClassName .. "_C");
    for idx, modActor in ipairs(modActors) do
        if modActor:IsA("/Game/Mods/ServerTools/" .. modActorClassName .. "." .. modActorClassName .. "_C") then
            return modActor
        end
    end
    return nil
end

-- Thanks to Yangff
local function decodeFGUIdToStr(guidIn)
    return string.format("%08X%08X%08X%08X", guidIn.A & 0xffffffff, guidIn.B & 0xffffffff, guidIn.C & 0xffffffff, guidIn.D & 0xffffffff)
end


local function dumpStruct(StructObj)
    StructObj:ForEachProperty(function(Property)
        print(string.format("0x%04X    %s %s", Property:GetOffset_Internal(), Property:GetClass():GetFName():ToString(), Property:GetFName():ToString()))
    end)
end

local modActor = nil

-- Print to both stdout and the ue4ss console
local printOrg = print
local function print(sMsg)
    local outString = string.format("[ServerTools] %s\n", sMsg)
    printOrg(outString)
    io.write(outString)
end

local function dumpEverythingNow()
    print("Dumping all objects...")
    DumpAllObjects()
    print("Generating CXX...")
    GenerateSDK()
    print("Generating UHT...")
    GenerateUHTCompatibleHeaders()
    print("Dumping SMs...")
    DumpStaticMeshes()
    print("Dumping Actors...")
    DumpAllActors()
    print("Dumping USMAP...")
    DumpUSMAP()
    print("...dump done.")
end

function AfterFirstTick()
    --dumpEverythingNow()
    --DumpAllObjects()
    print("Server up!")
end

-- Run

--[[
NotifyOnNewObject("/Script/Engine.NetConnection", function (Context)
    print("! New NetConnection")
end)
]]--

RegisterCustomEvent("OnServerToolsInit", function ()
    --DumpAllObjects()
    local errored = false
   
    local strModPrintFunc = "/Game/Mods/ServerTools/" .. modActorClassName .. "." .. modActorClassName .. "_C:ModPrint"
    if StaticFindObject(strModPrintFunc):IsValid() then
        RegisterHook(strModPrintFunc, function(self, InString)
            print(InString:get():ToString())
        end)
    else
        errored = true
    end
    
    local strAfterFirstTickFunc = "/Game/Mods/ServerTools/" .. modActorClassName .. "." .. modActorClassName .. "_C:AfterFirstTick"
    if StaticFindObject(strAfterFirstTickFunc):IsValid() then
        RegisterHook(strAfterFirstTickFunc, function(self)
            AfterFirstTick()
        end)
    else
        errored = true
    end

    if errored then
        print("ServerTools failed to load one or more hooks. Missing/outdated ServerTools.pak?")
        return
    end
end)

RegisterCustomEvent("OnServerToolsPostInit", function ()
    modActor = getServerToolsModActor()
    if modActor == nil then
        print("Main mod failed to load. Missing/outdated ServerTools.pak?")
    else
        RegisterHook("/Script/Pal.PalPlayerState:EnterChat_Receive", function(PalPlayerState, ChatMessage)
            local MsgStruct = ChatMessage:get()
            
            -- need to deserialize the entire struct in order, otherwise UE crashes
            local byteCategory = MsgStruct.Category
            local strSender = MsgStruct.Sender:ToString()
            local guidstructSender = MsgStruct.SenderPlayerUId -- ignored
            local strMessage = MsgStruct.Message:ToString()
            local guidstructReceiver = MsgStruct.ReceiverPlayerUId -- ignored for now (TODO: guid > playername lookup function, need to deserialize guid str)
            
            modActor:OnChatRecv(byteCategory, FText(strSender), FText(strMessage))
        end)
        
        NotifyOnNewObject("/Script/Pal.PalPlayerState", function (PalPlayerState)
            modActor:OnNewPalPlayerState(PalPlayerState)
        end)
        
        -- Could be used to receive bounce-backs from fake players
        --[[
        RegisterHook("/Script/Pal.PalGameStateInGame:BroadcastChatMessage", function(BroadcastChatMessage, ChatMessage)
            
            local MsgStruct = ChatMessage:get()
            
            -- need to deserialize the entire struct in order, otherwise UE crashes
            local byteCategory = MsgStruct.Category
            local strSender = MsgStruct.Sender:ToString()
            local guidstructSender = MsgStruct.SenderPlayerUId -- ignored
            local strMessage = MsgStruct.Message:ToString()
            local guidstructReceiver = MsgStruct.ReceiverPlayerUId -- ignored for now (TODO: guid > playername lookup function, need to deserialize guid str)
            
            print("Got broadcast, msg = " .. strMessage)
        end)
        ]]--
    end
end)
