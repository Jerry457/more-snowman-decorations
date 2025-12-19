local assets = {
    Asset("ANIM", "anim/shortcake.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddNetwork()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("shortcake")
    inst.AnimState:SetBuild("shortcake")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab("shortcake", fn, assets)
