local AddComponentAction = AddComponentAction
local AddAction = AddAction
GLOBAL.setfenv(1, GLOBAL)

local snowman_utils = require("snowman_utils")
local SetSnowmanSkin = snowman_utils.SetSnowmanSkin
local WaxedSnowmanCanStackHook = snowman_utils.WaxedSnowmanCanStackHook

local COMPONENT_ACTIONS = GlassicAPI.UpvalueUtil.GetUpvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")
local SCENE = COMPONENT_ACTIONS.SCENE
local USEITEM = COMPONENT_ACTIONS.USEITEM
local POINT = COMPONENT_ACTIONS.POINT
local EQUIPPED = COMPONENT_ACTIONS.EQUIPPED
local INVENTORY = COMPONENT_ACTIONS.INVENTORY

local actions = {
    FAKE_DECORATESNOWMAN = Action({ distance=1.5, encumbered_valid=true, invalid_hold_action=true })
}

for name, action in pairs(actions) do
    action.id = name
    action.str = STRINGS.ACTIONS[name] or name
    AddAction(action)
end

local _DECORATESNOWMAN_fn = ACTIONS.DECORATESNOWMAN.fn
ACTIONS.DECORATESNOWMAN.fn = function(act)
    if act.target then
        if act.target.components.fakesnowmandecoratable then
            act.target = act.target.entity:GetParent()
        end
    end

    local skin_type = act.target and act.target:HasTag("snowman") and act.target.skin_type or nil

    if act.doer and act.target and act.target.components.snowmandecoratable then
        if act.invobject then
            if act.invobject.components.snowmandecoratable == nil then
                --Start decorating
                local success, reason = act.target.components.snowmandecoratable:CanBeginDecorating(act.doer)
                if not success then
                    return false, reason
                end

                --Silent fail for decorating in the dark
                if CanEntitySeeTarget(act.doer, act.target) then
                    if act.invobject.components.equippable and act.invobject.components.equippable.equipslot == EQUIPSLOTS.HEAD then
                        --Equip hat
                        act.target.components.snowmandecoratable:EquipHat(act.invobject)
                    else
                        --Begin decorating with items
                        act.target.components.snowmandecoratable:BeginDecorating(act.doer, act.invobject)
                    end
                end
                return true
            else
                --Stacking throwable snowballs
                local success, reason = act.target.components.snowmandecoratable:CanStack(act.doer, act.invobject)
                if not success then
                    return false, reason
                end

                --Silent fail for stacking in the dark
                if CanEntitySeeTarget(act.doer, act.target) then
                    local target = act.target
                    if not target:HasTag("heavy") then
                        local x, y, z = target.Transform:GetWorldPosition()
                        local size = target.components.snowmandecoratable:GetSize()
                        if target.components.stackable and target.components.stackable:IsStack() then
                            target.components.stackable:Get():Remove()
                            target.components.inventoryitem:DoDropPhysics(x, y, z, true)
                        else
                            target:Remove()
                        end
                        target = SpawnPrefab("snowman")
                        SetSnowmanSkin(target, skin_type)
                        target:SetSize(size)
                        target.Transform:SetPosition(x, 0, z)
                    end
                    target.components.snowmandecoratable:Stack(act.doer, act.invobject)
                end
                return true
            end
        elseif act.doer.components.inventory and act.doer.components.inventory:IsHeavyLifting() then
            --Stacking large snowballs
            local item = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if item and item.components.snowmandecoratable then
                local success, reason = act.target.components.snowmandecoratable:CanStack(act.doer, item)
                if not success then
                    return false, reason
                end

                --Silent fail for stacking in the dark
                if CanEntitySeeTarget(act.doer, act.target) then
                    local target = act.target
                    if not target:HasTag("heavy") then
                        local x, y, z = target.Transform:GetWorldPosition()
                        local size = target.components.snowmandecoratable:GetSize()
                        if target.components.stackable and target.components.stackable:IsStack() then
                            target.components.stackable:Get():Remove()
                            target.components.inventoryitem:DoDropPhysics(x, y, z, true)
                        else
                            target:Remove()
                        end
                        target = SpawnPrefab("snowman")
                        SetSnowmanSkin(target, skin_type)
                        target:SetSize(size)
                        target.Transform:SetPosition(x, 0, z)
                    end
                    target.components.snowmandecoratable:Stack(act.doer, item)
                end
                return true
            end
        end
    end
end


local _HAMMER_fn = ACTIONS.HAMMER.fn
ACTIONS.HAMMER.fn = function(act, ...)
    if act.target then
        if act.target.components.fakesnowmandecoratable then
            act.target = act.target.entity:GetParent()
        end
    end
    return _HAMMER_fn(act, ...)
end

local _HAMMER_validfn = ACTIONS.HAMMER.validfn
ACTIONS.HAMMER.validfn = function(act, ...)
    if act.target then
        if act.target.components.fakesnowmandecoratable then
            act.target = act.target.entity:GetParent()
        end
    end
    return _HAMMER_validfn(act, ...)
end

local _WAX_fn = ACTIONS.WAX.fn
ACTIONS.WAX.fn = function(act, ...)
    if act.target then
        if act.target.components.fakesnowmandecoratable then
            act.target = act.target.entity:GetParent()
        end
    end
    return _WAX_fn(act, ...)
end

local _SCENE_snowmandecoratable = SCENE.snowmandecoratable
AddComponentAction("SCENE", "fakesnowmandecoratable", function(inst, ...)
    if inst.components.fakesnowmandecoratable then
        local parent = inst.entity:GetParent()
        if parent then
            return WaxedSnowmanCanStackHook(parent, _SCENE_snowmandecoratable, parent, ...)
        end
    end
end)

SCENE.snowmandecoratable = function(inst, ...)
    return WaxedSnowmanCanStackHook(inst, _SCENE_snowmandecoratable, inst, ...)
end

local _USEITEM_snowmandecor = USEITEM.snowmandecor
USEITEM.snowmandecor = function(inst, doer, target, ...)
    target = (target.components.fakesnowmandecoratable and target.entity:GetParent()) or target
    return WaxedSnowmanCanStackHook(target, _USEITEM_snowmandecor, inst, doer, target, ...)
end

local _USEITEM_snowmandecoratable = USEITEM.snowmandecoratable
USEITEM.snowmandecoratable = function(inst, doer, target, ...)
    target = (target.components.fakesnowmandecoratable and target.entity:GetParent()) or target
    return WaxedSnowmanCanStackHook(target, _USEITEM_snowmandecoratable, inst, doer, target, ...)
end

local _EQUIPPED_snowmandecoratable = EQUIPPED.snowmandecoratable
EQUIPPED.snowmandecoratable = function(inst, doer, target, ...)
    target = (target.components.fakesnowmandecoratable and target.entity:GetParent()) or target
    return WaxedSnowmanCanStackHook(target, _EQUIPPED_snowmandecoratable, inst, doer, target, ...)
end

local _USEITEM_tool = USEITEM.tool
USEITEM.tool = function(inst, doer, target, ...)
    target = (target.components.fakesnowmandecoratable and target.entity:GetParent()) or target
    return _USEITEM_tool(inst, doer, target, ...)
end

local _USEITEM_wax = USEITEM.wax
USEITEM.wax = function(inst, doer, target, ...)
    target = (target.components.fakesnowmandecoratable and target.entity:GetParent()) or target
    return _USEITEM_wax(inst, doer, target, ...)
end

local _EQUIPPED_tool = EQUIPPED.tool
EQUIPPED.tool = function(inst, doer, target, ...)
    target = (target.components.fakesnowmandecoratable and target.entity:GetParent()) or target
    return _EQUIPPED_tool(inst, doer, target, ...)
end

local _EQUIPPED_wax = EQUIPPED.wax
EQUIPPED.wax = function(inst, doer, target, ...)
    target = (target.components.fakesnowmandecoratable and target.entity:GetParent()) or target
    return _EQUIPPED_wax(inst, doer, target, ...)
end
