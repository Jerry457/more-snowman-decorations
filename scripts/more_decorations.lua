
local MoreDecorations = {
    watermelon = { canflip = true },
    watermelon_cooked = { canflip = true },
    asparagus_cooked = { canflip = true },
    lightbulb = {
        canflip = true,
        bloome_ffect = "shaders/anim.ksh",
        light = {
            falloff = 0.7,
            intensity = 0.5,
            radius = 0.5,
            colour = Vector3(237, 237, 209),
        },
    },
    nightmarefuel = {
        canflip = true,
        custom_animation_num_rots = 16,
        use_point_filtering = true,
        mult_colour = { 1, 1, 1, 0.5 },
    },
    winter_ornament_light1 = {
        canflip = true,
        bloome_ffect = "shaders/anim.ksh",
        light = {
            falloff = 0.7,
            intensity = 0.5,
            radius = 0.5,
            colour = Vector3(255, 25.5, 25.5),
        },
        custom_animation_num_rots = 16,
    },
}
return MoreDecorations
