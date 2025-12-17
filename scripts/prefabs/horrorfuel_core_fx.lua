local function fn()
    local inst = CreateEntity()
    inst:AddTag("FX")

    inst.entity:AddNetwork()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.AnimState:SetBank("horrorfuel_decoration")
    inst.AnimState:SetBuild("horrorfuel_decoration")
    inst.AnimState:SetFinalOffset(1)

    return inst
end

return Prefab("horrorfuel_core_fx", fn)
