local function OnRemoveEntity(inst)
    local parent = inst.entity:GetParent()
    if parent and parent.highlightchildren then
        table.removearrayvalue(parent.highlightchildren, inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")

    inst.persists = false

    inst.entity:AddNetwork()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddLight()

    inst.Light:Enable(false)

    inst.OnRemoveEntity = OnRemoveEntity

    return inst
end

return Prefab("snowman_decorate", fn)
