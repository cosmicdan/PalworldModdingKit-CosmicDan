--[[
    ServerTools
   
    This is the very first entry point for the Server Tools mod. All functions are provided in external files and documented as necessary.
    
    By Daniel "CosmicDan" Connolly
]]--

-- define mod meta
local lua_mod_name = "Server Tools"
local lua_mod_version = "0.2.1"

-- include mod deps
require ("cosmiclib")
require ("cosmic_bp_loader")

-- setup mod dep overrides
local print = function(message) cosmiclib_print("Server Tools Loader", message) end
local error = function(message) cosmiclib_error("Server Tools Loader", message) end

-- define mod loader callbacks
local function on_mod_class_missing()
    --DumpAllObjects()
    error("Could not find ServerToolsCore, is the pak file installed...?")
end

local function on_mod_spawn_failed()
    --DumpAllObjects()
    error("ServerToolsCore is not a valid actor, fix me!")
end

local function on_spawned(mod_actor)
    require("servertools")
    server_tools_init(mod_actor)
end

print("Server starting...")

-- Finally, load our logic mod
bp_loader_load("/Game/Mods/ServerTools/ServerToolsCore", "ServerToolsCore_C", on_mod_class_missing, on_mod_spawn_failed, on_spawned)
