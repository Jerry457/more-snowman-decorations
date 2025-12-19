local AddPrototyperDef = AddPrototyperDef
GLOBAL.setfenv(1, GLOBAL)

TECH.SNOWMAN_TECHNOLOGY = { SNOWMAN_TECHNOLOGY = 1 }
GlassicAPI.AddPrototyperTrees("SNOWMAN_TECHNOLOGY", { SNOWMAN_TECHNOLOGY = 1 })
GlassicAPI.AddTech("SNOWMAN_TECHNOLOGY")

AddPrototyperDef("snowman", {
    icon_atlas = "images/snowball_crafting_menu_icons.xml",
    icon_image = "snowman_technology.tex",
    is_crafting_station = true,
    -- action_str = "FROTHERN",
    filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.SNOWMAN_TECHNOLOGY
})

GlassicAPI.AddRecipe(
    "snowball_item",
    { Ingredient("snowball_item", 1) },
    TECH.SNOWMAN_TECHNOLOGY,
    {},
    { "CRAFTING_STATION" }
)

GlassicAPI.AddRecipe(
    "shortcake",
    { Ingredient("twigs", 2) },
    TECH.SNOWMAN_TECHNOLOGY,
    {},
    { "CRAFTING_STATION" }
)
