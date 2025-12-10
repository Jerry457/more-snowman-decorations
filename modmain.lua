local extra_decorations = {
    ["watermelon_cooked"] = { canflip = true },
    ["asparagus_cooked"] = { canflip = false },
}

Assets = {
    Asset("ANIM", "anim/item_rotate.zip"),
}
for prefab in pairs(extra_decorations) do
    table.insert(Assets, Asset("ANIM", "anim/" .. prefab .. "_decoration.zip"))
end

local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local SnowmanDecoratable = require("components/snowmandecoratable")
local _, ITEM_DATA = debug.getupvalue(SnowmanDecoratable.GetItemData, 1)

if not ITEM_DATA then
    return ITEM_DATA
end

for prefab, data in pairs(extra_decorations) do
    ITEM_DATA[hash(prefab)] = data
    data.name = prefab
    data.bank = "item_rotate"
    data.build = prefab .. "_decoration"
    data.anim = "snowman_decor"
    AddPrefabPostInit(prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end

        inst:AddComponent("snowmandecor")
    end)
end

TUNING.SNOWMAN_MAX_DECOR = {}
