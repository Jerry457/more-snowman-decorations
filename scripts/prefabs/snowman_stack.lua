local function AttachParent(inst, parent)
    inst.entity:SetParent(parent.entity)

    -- inst.components.highlightchild:SetOwner(parent)
    if parent.components.colouradder ~= nil then
        parent.components.colouradder:AttachChild(inst)
    end

    return inst
end

local function DisplayNameFn(inst)
    local parent = inst.entity:GetParent()
    if parent then
        return parent:GetDisplayName()
    end
end

local function GetDescription(self, viewer, ...)
    local parent = self.inst.entity:GetParent()
    if parent and parent.components.inspectable then
        return parent.components.inspectable:GetDescription(viewer, ...)
    end
end

local function fn()
    local inst = CreateEntity()

    -- inst:AddTag("FX")

    inst.entity:AddNetwork()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("snowball")
    inst.AnimState:SetBuild("snowball")

    inst:AddComponent("highlightchild")

    inst.displaynamefn = DisplayNameFn

    inst:AddComponent("fakesnowmandecoratable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("inspectable")
    inst.components.inspectable.GetDescription = GetDescription

    inst:AddComponent("colouradder")

    inst.AttachParent = AttachParent

    return inst
end

return Prefab("snowman_stack", fn)
