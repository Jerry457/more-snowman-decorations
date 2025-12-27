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
    "snowman_med_recipe",
    { Ingredient("snowball_item", 3) },
    TECH.SNOWMAN_TECHNOLOGY,
    { placer = "snowman_med_recipe_placer", image = "snowman_med.tex", description = "snowball_item" },
    { "CRAFTING_STATION" }
)

GlassicAPI.AddRecipe(
    "snowman_large_recipe",
    { Ingredient("snowball_item", 5) },
    TECH.SNOWMAN_TECHNOLOGY,
    { placer = "snowman_large_recipe_placer", image = "snowman_large.tex", description = "snowball_item" },
    { "CRAFTING_STATION" }
)

GlassicAPI.AddRecipe(
    "snowman_giant_recipe",
    { Ingredient("snowball_item", 7) },
    TECH.SNOWMAN_TECHNOLOGY,
    { placer = "snowman_giant_recipe_placer", image = "snowman_giant.tex", description = "snowball_item" },
    { "CRAFTING_STATION" }
)

GlassicAPI.AddRecipe(
    "snowman_epic_recipe",
    { Ingredient("snowball_item", 9) },
    TECH.SNOWMAN_TECHNOLOGY,
    { placer = "snowman_epic_recipe_placer", image = "snowman_epic.tex", description = "snowball_item" },
    { "CRAFTING_STATION" }
)

GlassicAPI.AddRecipe(
    "shortcake",
    { Ingredient("twigs", 2) },
    TECH.SNOWMAN_TECHNOLOGY,
    {},
    { "CRAFTING_STATION" }
)
