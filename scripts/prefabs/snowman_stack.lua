
local function fn()
    local inst = CreateEntity()

    -- inst:AddTag("FX")

    inst.persists = false

    inst.entity:AddNetwork()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("snowball")
    inst.AnimState:SetBuild("snowball")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    return inst
end

return Prefab("snowman_stack", fn)
