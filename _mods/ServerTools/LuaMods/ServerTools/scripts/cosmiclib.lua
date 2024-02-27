--[[
    
]]

------------------------
-- Manually-overide these
------------------------
-- Print to both stdout and the ue4ss console
function cosmiclib_print(prefix, message)
    local outString = string.format("[" .. prefix .."] %s\n", message)
    io.write(outString)
    print(outString)
end
-- Errors write to stdout as well as log
function cosmiclib_error(prefix, message)
    local outString = string.format("[" .. prefix .."] [ERROR] %s\n", message)
    io.write(outString)
    error(outString)
end


------------------------
-- Called via cosmiclib.X
------------------------
cosmiclib = {}

local function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
 end
 cosmiclib.file_exists = file_exists
 
local function fguid_to_string(guidIn)
    return string.format("%08X%08X%08X%08X", guidIn.A & 0xffffffff, guidIn.B & 0xffffffff, guidIn.C & 0xffffffff, guidIn.D & 0xffffffff)
end
cosmiclib.fguid_to_string = fguid_to_string


local function dump_struct(StructObj)
    StructObj:ForEachProperty(function(Property)
        print(string.format("0x%04X    %s %s", Property:GetOffset_Internal(), Property:GetClass():GetFName():ToString(), Property:GetFName():ToString()))
    end)
end
cosmiclib.dump_struct = dump_struct

local function dump_everything()
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
cosmiclib.dump_everything = dump_everything
