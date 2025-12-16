if not GLOBAL.IsInFrontEnd() then return end

PreloadAssets = {
    Asset("ANIM", "anim/snowy_rarities.zip"),
}

Assets = {
    Asset("ANIM", "anim/snowy_rarities.zip"),
}

PrefabFiles = {
    "snowman_skins",
}

modimport("main/glassic_api_loader")

modimport("main/strings")
modimport("main/prefab_skins")

GlassicAPI.RegisterItemAtlas("snowball_inventoryimages", Assets)
