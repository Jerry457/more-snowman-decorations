local function AttachParent(inst, parent)
    inst.entity:SetParent(parent.entity)

    -- inst.components.highlightchild:SetOwner(parent)
    if parent.components.colouradder ~= nil then
        parent.components.colouradder:AttachChild(inst)
    end

    return inst
end

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

    inst:AddComponent("highlightchild")

    inst:SetPrefabNameOverride("snowman")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("colouradder")

    inst.AttachParent = AttachParent

    return inst
end

return Prefab("snowman_stack", fn)
