--[[
    
]]

require ("cosmiclib")
local print = function(message) cosmiclib_print("Server Tools", message) end
local error = function(message) cosmiclib_error("Server Tools", message) end

local fatal_abort_all = false

local mod_actor_path = "/Game/Mods/ServerTools/ServerToolsCore.ServerToolsCore_C"
local mod_actor = nil

-- temporary: check for old versions, abort if found
if cosmiclib.file_exists("Mods/ServerToolsLoader/enabled.txt") then
    error("The old ServerToolsLoader Lua mod is still installed. Please delete it and restart the server.")
    fatal_abort_all = true
end

-- Called as soon as the ServerToolsCore actor is spawned in the world
function server_tools_init(mod_actor_in)
    if fatal_abort_all then return end
    mod_actor = mod_actor_in
end

local function AfterFirstTick()
    --TODO: Kick all existing players, if any. Do it in BP.
    if mod_actor == nil then
        print("Internal error with Server Tools [Lua <> BP interop.]; broken mod installation...?")
    else
        RegisterHook("/Script/Pal.PalPlayerState:EnterChat_Receive", function(PalPlayerState, ChatMessage)
            --print("~~~ EnterChat_Receive")
            local MsgStruct = ChatMessage:get()
            
            -- need to deserialize the entire struct in order, otherwise UE crashes
            local byteCategory = MsgStruct.Category
            local strSender = MsgStruct.Sender:ToString()
            local guidstructSender = MsgStruct.SenderPlayerUId
            local strMessage = MsgStruct.Message:ToString()
            local guidstructReceiver = MsgStruct.ReceiverPlayerUId -- ignored for now (TODO: guid > playername lookup function, need to deserialize guid str)
            
            -- Thanks to Lyrthras for RetVal handling
            local RetVal = {}
            mod_actor:OnChatRecv(byteCategory, cosmiclib.fguid_to_string(guidstructSender), FText(strSender), FText(strMessage), RetVal)
            if RetVal.ChatConsumed == true then
                MsgStruct.Category = 15 -- setting an invalid (beyond currently-defined max) category byte allows to "cancel" the message
                return MsgStruct
            end
        end)
        
        NotifyOnNewObject("/Script/Pal.PalPlayerCharacter", function (PalPlayerCharacter)
            -- New player has joined the server, load them up
            mod_actor:OnNewPalPlayerCharacter(PalPlayerCharacter)
        end)

        RegisterHook(mod_actor_path .. ":CommandDump", function(self)
            ExecuteWithDelay(1, function() -- spawn async so we can return to command sender immediately
                dumpEverythingNow()
            end)
        end)
    end
end

RegisterCustomEvent("OnServerToolsInit", function ()
    local errored = false
   
    -- Print hook
    local strModPrintFunc = mod_actor_path .. ":ModPrint"
    if StaticFindObject(strModPrintFunc):IsValid() then
        RegisterHook(strModPrintFunc, function(_, message)
            print(message:get():ToString())
        end)
    else
        errored = true
    end
    
    -- After first tick hook
    -- TODO: Rename to OnFirstTickPost
    local strAfterFirstTickFunc = mod_actor_path .. ":AfterFirstTick"
    if StaticFindObject(strAfterFirstTickFunc):IsValid() then
        RegisterHook(strAfterFirstTickFunc, function(_)
            if fatal_abort_all then return end
            --dumpEverythingNow()
            --DumpAllObjects()
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

if FText == nil then
    print("ERROR: UE4SS 2.5 detected, mod will crash. Please update to UE4SS 3.0 or later.")
end