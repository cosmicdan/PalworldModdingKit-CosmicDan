--[[
    ServerTools Loader
    
    Bootstraps the main BP as well as some other essentials
    
    Daniel "CosmicDan" Connolly
]]--

-- Credits to Khejanin for this function
function getModActor()
    local modActors = FindAllOf("ModActor_C");
    for idx, modActor in ipairs(modActors) do
        if modActor:IsA("/Game/Mods/ServerTools/ModActor.ModActor_C") then
            return modActor
        end
    end
    return nil
end

-- Thanks to Yangff
function decodeFGUIdToStr(guidIn)
    return string.format("%08X%08X%08X%08X", guidIn.A & 0xffffffff, guidIn.B & 0xffffffff, guidIn.C & 0xffffffff, guidIn.D & 0xffffffff)
end


function dumpStruct(StructObj)
    StructObj:ForEachProperty(function(Property)
        print(string.format("0x%04X    %s %s", Property:GetOffset_Internal(), Property:GetClass():GetFName():ToString(), Property:GetFName():ToString()))
    end)
end

local modActor = nil

-- Print to both stdout and the ue4ss console
local printOrg = print
function print(sMsg)
    local outString = string.format("[ServerTools] %s\n", sMsg)
    printOrg(outString)
    io.write(outString)
end

function dumpEverythingNow()
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

print("Server starting...")

--[[
NotifyOnNewObject("/Script/Engine.NetConnection", function (Context)
    print("! New NetConnection")
end)
]]--

RegisterCustomEvent("OnServerToolsPreInit", function ()
    --DumpAllObjects()
    local errored = false
   
    local strModPrintFunc = "/Game/Mods/ServerTools/ModActor.ModActor_C:ModPrint"
    if StaticFindObject(strModPrintFunc):IsValid() then
        RegisterHook(strModPrintFunc, function(self, InString)
            print(InString:get():ToString())
        end)
    else
        errored = true
    end
    
    local strAfterFirstTickFunc = "/Game/Mods/ServerTools/ModActor.ModActor_C:AfterFirstTick"
    if StaticFindObject(strAfterFirstTickFunc):IsValid() then
        RegisterHook(strAfterFirstTickFunc, function(self)
            AfterFirstTick()
        end)
    else
        errored = true
    end

    if errored then
        print("ServerTools failed to load one or more hooks. Missing/outdated ServerTools.pak?")
    end
end)

RegisterCustomEvent("OnServerToolsInit", function ()
    modActor = getModActor()
    if modActor == nil then
        print("Main mod failed to load. Missing/outdated ServerTools.pak?")
    else
        RegisterHook("/Script/Pal.PalPlayerState:EnterChat_Receive", function(Context, ChatMessage)
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
        
        -- Note to self: For some reason this is fired for ANY message on the server side... maybe can use it to run commands...?
        --[[
        RegisterHook("/Script/Pal.PalGameStateInGame:BroadcastChatMessage", function(BroadcastChatMessage, ChatMessage)
            print("! Broadcast fired")
        end)
        ]]--
    end
end)
