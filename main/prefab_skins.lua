GLOBAL.setfenv(1, GLOBAL)

local snowman_utils = require("snowman_utils")
local SnowmanPrefabs = snowman_utils.SnowmanPrefabs
local SnowmanSkins = snowman_utils.SnowmanSkins

local skins = {}

for _, prefab in ipairs(SnowmanPrefabs) do
    _G[prefab .. "_clear_fn"] = function(inst)
        basic_clear_fn(inst, "snowball")
        inst.skin_type = nil
        inst:PushEvent("onskinschanged")
    end

    skins[prefab] = {}
    for i, skin_type in ipairs(SnowmanSkins) do
        table.insert(skins[prefab], prefab .. "_" .. skin_type)
    end
end

GlassicAPI.SkinHandler.AddModSkins(skins)
