local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.entity:SetCanSleep(false)

    inst.AnimState:SetBank("snowball")
    inst.AnimState:SetBuild("snowball")
    inst.AnimState:PlayAnimation("fx_place")

    inst.AnimState:SetFinalOffset(2)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("snowball_shatter_fx", fn)
