local prefabs = {}

local snowman_utils = require("snowman_utils")
local SnowmanPrefabs = snowman_utils.SnowmanPrefabs
local SnowmanSkins = snowman_utils.SnowmanSkins

for _, snow_prefab in ipairs(SnowmanPrefabs) do
    for i, skin_type in ipairs(SnowmanSkins) do
        local skin_build = "snowball_" .. skin_type

        table.insert(prefabs, CreatePrefabSkin(snow_prefab .. "_" .. skin_type, {
            base_prefab = snow_prefab,
            type = "item",
            rarity = "Reward",
            assets = { Asset("ANIM", "anim/".. skin_build .. ".zip") },
            init_fn = function(inst)
                GlassicAPI.BasicInitFn(inst)
                inst.skin_type = skin_type
                inst:PushEvent("onskinschanged")
            end,
            skin_tags = { "SNOWMAN_DUNGBALL" },
            build_name_override = skin_build,
            release_group = 87,
        }))
    end
end

return unpack(prefabs)
