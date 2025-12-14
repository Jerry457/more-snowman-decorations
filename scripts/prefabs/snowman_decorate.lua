-- local function OnRemoveEntity(inst)
--     local parent = inst.entity:GetParent()
--     if parent and parent.highlightchildren then
--         table.removearrayvalue(parent.highlightchildren, inst)
--     end
-- end

local function AttachHighLightParent(inst, parent)
    -- inst.entity:SetParent(parent.entity)

    -- inst.components.highlightchild:SetOwner(parent)
    if parent.components.colouradder ~= nil then
        parent.components.colouradder:AttachChild(inst)
    end

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")

    inst.entity:AddNetwork()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddLight()

    inst.Light:Enable(false)

    inst:AddComponent("highlightchild")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("colouradder")

    inst.AttachHighLightParent = AttachHighLightParent

    return inst
end

return Prefab("snowman_decorate", fn)
