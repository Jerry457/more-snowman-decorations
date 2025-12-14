
local function FinalOffset2(inst)
    inst.AnimState:SetFinalOffset(2)
end

local fxs = {
    {
        name = "snowball_shatter_fx",
        bank = "snowball",
        build = "snowball",
        anim = "fx_place",
		fn = FinalOffset2,
    },
    {
        name = "splash_snow_fx",
        bank = "splash",
        build = "splash_snow",
        anim = "idle",
        sound = "dontstarve_DLC001/common/firesupressor_impact",
    },
}

local function PlaySound(inst, sound)
    inst.SoundEmitter:PlaySound(sound)
end

local function MakeFx(data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.entity:SetCanSleep(false)

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        inst.AnimState:PlayAnimation(data.anim)

        if data.fn then
            data.fn(inst)
        end

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        if data.sound then
            inst:DoTaskInTime(data.sounddelay or 0, PlaySound, data.sound)
        end

        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end

    return Prefab(data.name, fn)
end

local prefabs = {}
for _, data in ipairs(fxs) do
    table.insert(prefabs, MakeFx(data))
end

return unpack(prefabs)
