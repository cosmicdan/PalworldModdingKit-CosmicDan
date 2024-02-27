--[[
    Custom BP mod loader. Avoids race conditions, and allows custom ModActor name.

    Based on original BPML in UE4SS 3.0

    LIMITATIONS (compared to original):
     - Does not fire Pre/Post init events. They can be unreliable and have limited usefulness anyway.
]]

-- Game-specific config
local world_object_path = "/Game/Pal/Maps/MainWorld_5/PL_MainWorld5.PL_MainWorld5"
local world_loop_wait_delay = 2 -- extremely tight loop so we can catch world creation ASAP
local world_loop_wait_max_seconds = 60

-- Internal
local asset_registry_helpers = nil
local asset_registry = nil


-- Based on CacheAssetRegistry from original BPML in UE4SS 3.0
local function cache_asset_registry()
    if asset_registry_helpers and asset_registry then return end -- already done

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

function bp_loader_load(mod_package_path, mod_asset_name, callback_mod_class_missing, callback_mod_spawn_failed, callback_spawned)
    local world_loop_wait_count = 0
    local world_loop_max_count = world_loop_wait_max_seconds * 1000 / world_loop_wait_delay

    -- TODO: Change this to a hook on world tick (and then unregister self)...?
    LoopAsync(world_loop_wait_delay, function()
        if world_loop_wait_count >= world_loop_max_count then -- wait 30 seconds max
            print("World has still not loaded after " .. world_loop_wait_max_seconds .. " seconds... aborting.")
            return true
        end	
            
        local world = StaticFindObject(world_object_path)
        if world:IsValid() then
            -- load assets registry
            local asset_reg = nil
            local asset_reg_helpers = StaticFindObject("/Script/AssetRegistry.Default__AssetRegistryHelpers")
            if not asset_reg_helpers:IsValid() then 
                error("Unable to find AssetRegistryHelpers; fix me!\n")
            else
                asset_reg = asset_reg_helpers:GetAssetRegistry()
                if not asset_reg:IsValid() then 
                    -- try default 
                    asset_reg = StaticFindObject("/Script/AssetRegistry.Default__AssetRegistryImpl")
                    if not asset_reg:IsValid() then
                        error("Could not find a valid AssetRegistry; fix me!\n")
                    end
                end
            end

            -- assets registry OK, load modactor
            local asset_data = {
                ["PackageName"] = FName(mod_package_path, EFindName.FNAME_Add),
                ["AssetName"] = FName(mod_asset_name, EFindName.FNAME_Add),
            }
            ExecuteInGameThread(function()
                local mod_class = asset_reg_helpers:GetAsset(asset_data)
                if not mod_class:IsValid() then
                    callback_mod_class_missing()
                else
                    -- TODO: set args
                    local mod_actor = world:SpawnActor(mod_class, {}, {})
                    if mod_actor:IsValid() then
                        callback_spawned(mod_actor)
                    else
                        callback_mod_spawn_failed(mod_actor)
                    end
                end
            end)


            return true
        end
    
        world_loop_wait_count = world_loop_wait_count + 1
        return false
    end)

end