if not GLOBAL.IsInFrontEnd() then return end

Assets = {
}

PrefabFiles = {
    "snowman_skins",
}

modimport("main/glassic_api_loader")

modimport("main/strings")
modimport("main/prefab_skins")

GlassicAPI.RegisterItemAtlas("snowball_inventoryimages", Assets)
