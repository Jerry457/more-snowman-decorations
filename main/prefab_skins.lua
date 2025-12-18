GLOBAL.setfenv(1, GLOBAL)

local SnowmanPrefabs = require("snowman_utils").SnowmanPrefabs
local SnowmanSkins = require("snowman_defs").SnowmanSkins

GlassicAPI.SkinHandler.SetRarity("Snowy", 0.2, { 170 / 255, 197 / 255, 229 / 255, 1 }, "Snowy", "snowy_rarities")

local skins = {}

for _, prefab in ipairs(SnowmanPrefabs) do
    _G[prefab .. "_clear_fn"] = function(inst)
        basic_clear_fn(inst, "snowball")
        inst.skin_type = nil
        inst.trail_colour = nil
        inst.AnimState:SetRayTestOnBB(false)
        inst:PushEvent("onskinschanged")
    end

    skins[prefab] = {}
    for skin_type in pairs(SnowmanSkins) do
        table.insert(skins[prefab], prefab .. "_" .. skin_type)
    end
end

GlassicAPI.SkinHandler.AddModSkins(skins)
