GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local extra_decorations = {
    watermelon = { canflip = true },
    watermelon_cooked = { canflip = true },
    asparagus_cooked = { canflip = true },
    winter_ornament_light1 = { canflip = true },
    lightbulb = {
        canflip = true,
        light = {
            falloff = 0.7,
            intensity = 0.5,
            radius = 0.5,
            colour = {237 / 255, 237 / 255, 209 / 255}
        }
    },
    nightmarefuel = {
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
    data.bank = data.bank or (data.custom_animation and (prefab .. "_decoration") or "item_rotate")
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

local function UseCustomAnimation(itemdata, inst, flip, rot)
    local custom_animation = itemdata.custom_animation
    if not custom_animation then
        return
    end

    local animation = itemdata.anim .. (flip and itemdata.canflip and "_flip_" or "_") .. (rot - 1)
    inst.AnimState:PlayAnimation(animation, true)
    if custom_animation.mult_colour then
        inst.AnimState:SetMultColour(unpack(custom_animation.mult_colour))
    end
    if custom_animation.use_point_filtering then
        inst.AnimState:UsePointFiltering(true)
    end

    inst.entity:AddLight()
    inst.Light:SetFalloff(custom_animation.light.falloff or 1)
    inst.Light:SetIntensity(custom_animation.light.intensity or 1)
    inst.Light:SetRadius(custom_animation.light.radius or 2)
    inst.Light:SetColour(unpack(custom_animation.colour or {1, 1, 1, 1}))
    inst.Light:Enable(true)

    inst.AnimState:Resume()
end

local _CreateDecor, i, _DoDecor = UpvalueUtil.GetUpvalue(SnowmanDecoratable.ApplyDecor, "_DoDecor.CreateDecor")
local function CreateDecor(itemdata, rot, flip, ...)
    local inst = _CreateDecor(itemdata, rot, flip, ...)
    UseCustomAnimation(itemdata, inst, flip, rot)
    return inst
end
debug.setupvalue(_DoDecor, i, CreateDecor)

if GetModConfigData("ModifySnowmanDecorateLimit") then
    TUNING.SNOWMAN_MAX_DECOR = { 9999, 9999, 9999 }
end

local ModifySnowmanStackHeight = GetModConfigData("ModifySnowmanStackHeight") or 6
if ModifySnowmanStackHeight > 6 then
    UpvalueUtil.SetUpvalue(SnowmanDecoratable.CanStack, "MAX_STACK_HEIGHT", ModifySnowmanStackHeight)
end

----------------------------------------------------------------------------------------------------------------
-----------------------------------------[[SnowmanDecoratingScreen]]--------------------------------------------
----------------------------------------------------------------------------------------------------------------
local SnowmanDecoratingScreen = require("screens/redux/snowmandecoratingscreen")
local TrueScrollList = require("widgets/truescrolllist")

local IMG_SCALE = 0.75
local DISPLAY_MAX_HEIGH = 550
AddClassPostConstruct("screens/redux/snowmandecoratingscreen", function(self, owner, target, obj)
    local height = self:GetStackHeight() * IMG_SCALE

    -- if height <= DISPLAY_MAX_HEIGH then
    --     return
    -- end

    local root = self.root
    local snowmanroot = self.snowmanroot
    root.scrollbar_height = DISPLAY_MAX_HEIGH
    root.scrollbar_offset = { 300, 20 }

    root.end_pos = 20
    root.scroll_per_click = 1
    root.current_scroll_pos = root.end_pos / 2

    TrueScrollList.BuildScrollBar(root)
    root.GetSlideStart = TrueScrollList.GetSlideStart
    root.GetSlideRange = TrueScrollList.GetSlideRange
    root.GetPositionScale = TrueScrollList.GetPositionScale
    root.DoDragScroll = TrueScrollList.DoDragScroll

    function root:Scroll(scroll_step)
        self.current_scroll_pos = math.clamp(self.current_scroll_pos + scroll_step, 1, self.end_pos)
        self:RefreshView()
    end

    function root:RefreshView()
        self.position_marker:SetPosition(0, self:GetSlideStart() - self:GetPositionScale() * self:GetSlideRange())
        snowmanroot:SetPosition(0, -height + height * self:GetPositionScale())
        -- snowmanroot:SetPosition(0, -height + DISPLAY_MAX_HEIGH / 2 + (height - DISPLAY_MAX_HEIGH) * self:GetPositionScale())
    end

    root:RefreshView()
end)

function SnowmanDecoratingScreen:GetStackHeight()
	local height = 0
	for i, snowball in ipairs(self.stacks) do
		height = snowball.ypos
        if snowball.stackdata then
            height = height + snowball.stackdata.heights[1]
        end
	end
    return height
end

local _StartDraggingItem = SnowmanDecoratingScreen.StartDraggingItem
function SnowmanDecoratingScreen:StartDraggingItem(obj, ...)
    _StartDraggingItem(self, obj, ...)
    UseCustomAnimation(self.dragitem.itemdata, self.dragitem.inst, self.dragitem.flip, self.dragitem.rot)
end

local _DoAddItemAt = SnowmanDecoratingScreen.DoAddItemAt
function SnowmanDecoratingScreen:DoAddItemAt(x, y, itemhash, itemdata, rot, flip, ...) --snowball local space
    local decor = _DoAddItemAt(self, x, y, itemhash, itemdata, rot, flip, ...)
    UseCustomAnimation(itemdata, decor.inst, flip, rot)
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
        UseCustomAnimation(self.dragitem.itemdata, self.dragitem.inst, self.dragitem.flip, self.dragitem.rot)
    end
end
