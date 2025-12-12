GLOBAL.setfenv(1, GLOBAL)

SnowPrefabs = {
    "snowman",
    "snowball_item",
    "snowman_stack",
}

SnowSkins = {
    "dungball",
}

local skins = {}

for _, snow_prefab in ipairs(SnowPrefabs) do
    _G[snow_prefab .. "_clear_fn"] = function(inst)
        basic_clear_fn(inst, "snowball")
        inst.skin_type = nil
        inst:PushEvent("onskinschanged")
    end

    skins[snow_prefab] = {}
    for i, skin_type in ipairs(SnowSkins) do
        table.insert(skins[snow_prefab], snow_prefab .. "_" .. skin_type)
    end
end

GlassicAPI.SkinHandler.AddModSkins(skins)
