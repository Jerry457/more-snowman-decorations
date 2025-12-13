GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

modimport("main/glassic_api_loader.lua")
modimport("main/prefab_skins.lua")
modimport("main/postinit.lua")

Assets = {
    Asset("ANIM", "anim/item_rotate.zip"),
}

PrefabFiles = {
    "snowman_skins",
    "snowman_decorate",
    "snowman_stack",
}

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
