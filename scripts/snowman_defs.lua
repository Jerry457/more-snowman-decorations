local SnowmanSkins = {
    "dungball",
}

local MoreDecorations = {
    watermelon = { canflip = true },
    watermelon_cooked = { canflip = true },
    asparagus_cooked = { canflip = true },
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
    winter_ornament_boss_antlion = { canflip = true },
    winter_ornament_boss_bearger = { canflip = true },
    winter_ornament_boss_beequeen = { canflip = true },
    winter_ornament_boss_celestialchampion1 = { canflip = true },
    winter_ornament_boss_celestialchampion2 = { canflip = true },
    winter_ornament_boss_celestialchampion3 = { canflip = true },
    winter_ornament_boss_celestialchampion4 = { canflip = true },
    winter_ornament_boss_crabkingpearl = { canflip = true },
    winter_ornament_boss_crabking = { canflip = true },
    winter_ornament_boss_daywalker2 = { canflip = true },
    winter_ornament_boss_daywalker = { canflip = true },
    winter_ornament_boss_deerclops = { canflip = true },
    winter_ornament_boss_dragonfly = { canflip = true },
    winter_ornament_boss_eyeofterror1 = { canflip = true },
    winter_ornament_boss_eyeofterror2 = { canflip = true },
    winter_ornament_boss_fuelweaver = { canflip = true },
    winter_ornament_boss_klaus = { canflip = true },
    winter_ornament_boss_krampus = { canflip = true },
    winter_ornament_boss_malbatross = { canflip = true },
    winter_ornament_boss_minotaur = { canflip = true },
    winter_ornament_boss_moose = { canflip = true },
    winter_ornament_boss_mutatedbearger = { canflip = true },
    winter_ornament_boss_mutateddeerclops = { canflip = true },
    winter_ornament_boss_mutatedwarg = { canflip = true },
    winter_ornament_boss_noeyeblue = { canflip = true },
    winter_ornament_boss_noeyered = { canflip = true },
    winter_ornament_boss_sharkboi = { canflip = true },
    winter_ornament_boss_toadstool = { canflip = true },
    winter_ornament_boss_toadstool_misery = { canflip = true },
    winter_ornament_boss_wagstaff = { canflip = true },
    winter_ornament_boss_wormboss = { canflip = true },
    winter_ornament_shadowthralls = { canflip = true },
    winter_ornament_boss_hermithouse = { canflip = true },
    winter_ornament_boss_pearl = { canflip = true },
    winter_ornament_festivalevents1 = { canflip = true },
    winter_ornament_festivalevents2 = { canflip = true },
    winter_ornament_festivalevents3 = { canflip = true },
    winter_ornament_festivalevents4 = { canflip = true },
    winter_ornament_festivalevents5 = { canflip = true },
    winter_food1 = { canflip = true },
    winter_food2 = { canflip = true },
    winter_food3 = { canflip = true },
    winter_food4 = { canflip = true },
    winter_food5 = { canflip = true },
    winter_food6 = { canflip = true },
    winter_food7 = { canflip = true },
    winter_food8 = { canflip = true },
    winter_food9 = { canflip = true },
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
}

local winter_ornament_light_colours = {
    Vector3(255, 25.5, 25.5),
    Vector3(25.5, 255, 25.5),
    Vector3(127.5, 127.5, 255),
    Vector3(255, 255, 255),
    Vector3(255, 25.5, 25.5),
    Vector3(25.5, 255, 25.5),
    Vector3(127.5, 127.5, 255),
    Vector3(255, 255, 255),
}

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

for i, colour in ipairs(winter_ornament_light_colours) do
    MoreDecorations["winter_ornament_light" .. i] = {
        canflip = true,
        bloome_ffect = "shaders/anim.ksh",
        light = {
            falloff = 0.7,
            intensity = 0.5,
            radius = 0.5,
            colour = colour,
        },
        fn = winter_ornament_light_flash
    }
end

return {
    SnowmanSkins = SnowmanSkins,
    MoreDecorations = MoreDecorations,
}
