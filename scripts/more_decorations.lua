local function winter_ornament_light_flash(inst, itemdata)
    inst.AnimState:OverrideSymbol("item", itemdata.build, "light_on")
    if not TheWorld.ismastersim then
        return
    end
    inst:DoPeriodicTask(1.2, function()
        local light = not inst.Light:IsEnabled()
        inst.AnimState:OverrideSymbol("item", itemdata.build, "light_" .. (light and "on" or "off"))
        inst.Light:Enable(light)
    end)
end

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
    winter_ornament_plain1 = { canflip = true },
    winter_ornament_plain2 = { canflip = true },
    winter_ornament_plain3 = { canflip = true },
    winter_ornament_plain4 = { canflip = true },
    winter_ornament_plain5 = { canflip = true },
    winter_ornament_plain6 = { canflip = true },
    winter_ornament_plain7 = { canflip = true },
    winter_ornament_plain8 = { canflip = true },
    winter_ornament_plain9 = { canflip = true },
    winter_ornament_plain10 = { canflip = true },
    winter_ornament_plain11 = { canflip = true },
    winter_ornament_plain12 = { canflip = true },
    winter_ornament_fancy1 = { canflip = true },
    winter_ornament_fancy2 = { canflip = true },
    winter_ornament_fancy3 = { canflip = true },
    winter_ornament_fancy4 = { canflip = true },
    winter_ornament_fancy5 = { canflip = true },
    winter_ornament_fancy6 = { canflip = true },
    winter_ornament_fancy7 = { canflip = true },
    winter_ornament_fancy8 = { canflip = true },
    winter_ornament_light1 = {
        canflip = true,
        bloome_ffect = "shaders/anim.ksh",
        light = {
            falloff = 0.7,
            intensity = 0.5,
            radius = 0.5,
            colour = Vector3(255, 25.5, 25.5),
        },
        fn = winter_ornament_light_flash
    },
}
return MoreDecorations
