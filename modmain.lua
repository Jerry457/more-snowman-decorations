GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local extra_decorations = {
    watermelon_cooked = { canflip = true },
    asparagus_cooked = { canflip = true },
    nightmarefuel = {
        bank = "nightmarefuel_decoration",
        canflip = true,
        custom_animation = {
            use_point_filtering = true,
            mult_colour = { 1, 1, 1, 0.5 },
        },
    }
}

Assets = {
    Asset("ANIM", "anim/item_rotate.zip"),
}

local UpvalueUtil = require("upvalueutil")
local SnowmanDecoratable = require("components/snowmandecoratable")

local ITEM_DATA = UpvalueUtil.GetUpvalue(SnowmanDecoratable.GetItemData, "ITEM_DATA")
for prefab, data in pairs(extra_decorations) do
    ITEM_DATA[hash(prefab)] = data
    data.name = prefab
    data.bank = data.bank or "item_rotate"
    data.build = data.build or (prefab .. "_decoration")
    data.anim = data.anim or "snowman_decor"

    if data.custom_animation then
        data.custom_animation.num_rots = data.custom_animation.num_rots or 16
    end

    table.insert(Assets, Asset("ANIM", "anim/" .. data.build .. ".zip"))

    AddPrefabPostInit(prefab, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        inst:AddComponent("snowmandecor")
    end)
end

local function UseCustomAnimation(itemdata, AnimState, flip, rot)
    local custom_animation = itemdata.custom_animation
    if not custom_animation then
        return
    end

    local animation = itemdata.anim .. (flip and itemdata.canflip and "_flip_" or "_") .. (rot - 1)
    AnimState:PlayAnimation(animation, true)
    if custom_animation.mult_colour then
        AnimState:SetMultColour(unpack(custom_animation.mult_colour))
    end
    if custom_animation.use_point_filtering then
        AnimState:UsePointFiltering(true)
    end

    AnimState:Resume()
end

local _CreateDecor, i, _DoDecor = UpvalueUtil.GetUpvalue(SnowmanDecoratable.ApplyDecor, "_DoDecor.CreateDecor")
local function CreateDecor(itemdata, rot, flip, ...)
    local inst = _CreateDecor(itemdata, rot, flip, ...)
    UseCustomAnimation(itemdata, inst.AnimState, flip, rot)
    return inst
end
debug.setupvalue(_DoDecor, i, CreateDecor)

----------------------------------------------------------------------------------------------------------------
-----------------------------------------[[SnowmanDecoratingScreen]]--------------------------------------------
----------------------------------------------------------------------------------------------------------------
local SnowmanDecoratingScreen = require("screens/redux/snowmandecoratingscreen")

local _StartDraggingItem = SnowmanDecoratingScreen.StartDraggingItem
function SnowmanDecoratingScreen:StartDraggingItem(obj, ...)
    _StartDraggingItem(self, obj, ...)
    UseCustomAnimation(self.dragitem.itemdata, self.dragitem:GetAnimState(), self.dragitem.flip, self.dragitem.rot)
end

local _DoAddItemAt = SnowmanDecoratingScreen.DoAddItemAt
function SnowmanDecoratingScreen:DoAddItemAt(x, y, itemhash, itemdata, rot, flip, ...) --snowball local space
    local decor = _DoAddItemAt(self, x, y, itemhash, itemdata, rot, flip, ...)
    UseCustomAnimation(itemdata, decor:GetAnimState(), flip, rot)
    return decor
end

local _CanRotateDraggingItem = SnowmanDecoratingScreen.CanRotateDraggingItem
function SnowmanDecoratingScreen:CanRotateDraggingItem(...)
    if self.dragitem and self.dragitem.itemdata.custom_animation then
        return self.dragitem ~= nil and self.dragitem.shown and self.dragitem.itemdata.custom_animation.num_rots > 1
    end
    return _CanRotateDraggingItem(self, ...)
end

local _RotateDraggingItem = SnowmanDecoratingScreen.RotateDraggingItem
function SnowmanDecoratingScreen:RotateDraggingItem(delta, ...)
    local itemdata = self.dragitem.itemdata
    if self.dragitem and itemdata.custom_animation then
        local num_rots = itemdata.custom_animation.num_rots
        self.dragitem.rot = self.dragitem.rot + delta
        while self.dragitem.rot > num_rots do
            self.dragitem.rot = self.dragitem.rot - num_rots
        end
        while self.dragitem.rot < 1 do
            self.dragitem.rot = self.dragitem.rot + num_rots
        end
        local animation = itemdata.anim .. (self.dragitem.flip and itemdata.canflip and "_flip_" or "_") .. (self.dragitem.rot - 1)
        self.dragitem:GetAnimState():PlayAnimation(animation, true)
    else
        _RotateDraggingItem(self, delta, ...)
    end
end

local _FlipDraggingItem = SnowmanDecoratingScreen.FlipDraggingItem
function SnowmanDecoratingScreen:FlipDraggingItem(...)
    local num_rots = self.dragitem.itemdata.custom_animation and self.dragitem.itemdata.custom_animation.num_rots or 1
    local rot = ((num_rots - self.dragitem.rot + 1) % num_rots) + 1
    _FlipDraggingItem(self, ...)
    if self.dragitem and self.dragitem.itemdata.custom_animation then
        self.dragitem.rot = rot
        UseCustomAnimation(self.dragitem.itemdata, self.dragitem:GetAnimState(), self.dragitem.flip, self.dragitem.rot)
    end
end
