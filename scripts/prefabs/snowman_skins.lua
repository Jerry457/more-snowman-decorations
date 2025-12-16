local prefabs = {}

local SnowmanSkins = require("snowman_defs").SnowmanSkins
local SnowmanPrefabs = require("snowman_utils").SnowmanPrefabs

for _, snow_prefab in ipairs(SnowmanPrefabs) do
    for i, skin_type in ipairs(SnowmanSkins) do
        local skin_build = "snowball_" .. skin_type

        table.insert(prefabs, CreatePrefabSkin(snow_prefab .. "_" .. skin_type, {
            base_prefab = snow_prefab,
            type = "item",
            rarity = "Snowy",
            assets = { Asset("ANIM", "anim/".. skin_build .. ".zip") },
            init_fn = function(inst)
                GlassicAPI.BasicInitFn(inst)
                inst.skin_type = skin_type
                inst.AnimState:SetRayTestOnBB(inst.skin_type == "invisible")
                inst:PushEvent("onskinschanged")
            end,
            skin_tags = { string.upper(skin_build) },
            build_name_override = skin_build,
            release_group = 87,
        }))
    end
end

return unpack(prefabs)
