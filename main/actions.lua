local AddComponentAction = AddComponentAction
local AddAction = AddAction
GLOBAL.setfenv(1, GLOBAL)

local snowman_utils = require("snowman_utils")
local SpawnSnowmanHook = snowman_utils.SpawnSnowmanHook
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
ACTIONS.DECORATESNOWMAN.fn = function(act, ...)
    if act.target then
        if act.target.components.fakesnowmandecoratable then
            act.target = act.target.entity:GetParent()
        end
    end

    local skin_type = act.target and act.target:HasTag("snowmain") and act.target.skin_type or nil
    return snowman_utils.SpawnSnowmanHook(skin_type, _DECORATESNOWMAN_fn, act, ...)
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
