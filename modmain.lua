SnowmanConfig = {
    WaxedSnowmanCanStack = GetModConfigData("WaxedSnowmanCanStack"),
    UnlimitSnowmanDecorate = GetModConfigData("UnlimitSnowmanDecorate"),
    SnowmanStackHeight = GetModConfigData("SnowmanStackHeight") or 6,
    MoreFunSnowball = GetModConfigData("MoreFunSnowball"),
}
GLOBAL.SnowmanConfig = SnowmanConfig

modimport("main/glassic_api_loader.lua")
modimport("main/prefab_skins.lua")
modimport("main/postinit.lua")
modimport("main/prefab_files.lua")
modimport("main/actions.lua")

if SnowmanConfig.MoreFunSnowball then
    modimport("MoreFunSnowball/modmain.lua")
end

Assets = {
    Asset("ANIM", "anim/item_rotate.zip"),
}

GlassicAPI.RegisterItemAtlas("snowball_inventoryimages", Assets)

local Assets = Assets
local AddPrefabPostInit = AddPrefabPostInit
local GetModConfigData = GetModConfigData
GLOBAL.setfenv(1, GLOBAL)

local snowman_utils = require("snowman_utils")
local SnowmanDecoratable = require("components/snowmandecoratable")

local MoreDecorations = require("more_decorations")
local ITEM_DATA = GlassicAPI.UpvalueUtil.GetUpvalue(SnowmanDecoratable.GetItemData, "ITEM_DATA")
for prefab, data in pairs(MoreDecorations) do
    ITEM_DATA[hash(prefab)] = data
    data.name = prefab
    data.bank = data.bank or (data.custom_animation_num_rots and (prefab .. "_decoration") or "item_rotate")
    data.build = data.build or (prefab .. "_decoration")
    data.anim = data.anim or "snowman_decor"

    table.insert(Assets, Asset("ANIM", "anim/" .. data.build .. ".zip"))

    AddPrefabPostInit(prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        inst:AddComponent("snowmandecor")
    end)
end

for k, prefab in pairs(snowman_utils.SnowmanPrefabs) do
    AddPrefabPostInit(prefab, function(inst)
        inst:AddTag("snowman")
        inst.default_build = "snowball"
    end)
end
