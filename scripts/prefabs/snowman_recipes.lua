local snowman_utils = require("snowman_utils")
local SetSnowmanSkin = snowman_utils.SetSnowmanSkin

local function ChangeToSnowman(inst, size)
    local x, y, z = inst.Transform:GetWorldPosition()
    local snowman = SpawnPrefab("snowman")
    snowman:SetSize(size)
    SetSnowmanSkin(snowman, inst.skin_type)
    snowman.Transform:SetPosition(x, y, z)
    inst:Remove()
end

local function MakeSnowmanRecipe(size)
    local name = "snowman_" .. size .. "_recipe"
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:DoTaskInTime(0, ChangeToSnowman, size)

        return inst
    end

    PREFAB_SKINS[name] = PREFAB_SKINS.snowman
    PREFAB_SKINS_IDS[name] = PREFAB_SKINS_IDS.snowman

    return Prefab(name, fn),
        MakePlacer(name .. "_placer", "snowball", "snowball", "ground_" .. size)
end

local sizes = {
    "med",
    "large",
    "giant",
    "epic",
}

local prefabs = {}
for i, v in ipairs(sizes) do
    local recipe, placer = MakeSnowmanRecipe(v)
    table.insert(prefabs, recipe)
    table.insert(prefabs, placer)
end

return unpack(prefabs)
