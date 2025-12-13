local AddClassPostConstruct = AddClassPostConstruct
GLOBAL.setfenv(1, GLOBAL)

local SnowmanDecoratable = require("components/snowmandecoratable")
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
    SnowmanDecoratable.SnowmanDecorateCommon(self.dragitem.inst, self.dragitem.itemdata, self.dragitem.flip, self.dragitem.rot)
end

local _DoAddItemAt = SnowmanDecoratingScreen.DoAddItemAt
function SnowmanDecoratingScreen:DoAddItemAt(x, y, itemhash, itemdata, rot, flip, ...) --snowball local space
    local decor = _DoAddItemAt(self, x, y, itemhash, itemdata, rot, flip, ...)
    SnowmanDecoratable.SnowmanDecorateCommon(decor.inst, itemdata, flip, rot)
    return decor
end

local _CanRotateDraggingItem = SnowmanDecoratingScreen.CanRotateDraggingItem
function SnowmanDecoratingScreen:CanRotateDraggingItem(...)
    if self.dragitem and self.dragitem.itemdata.custom_animation_num_rots then
        return self.dragitem ~= nil and self.dragitem.shown and self.dragitem.itemdata.custom_animation_num_rots > 1
    end
    return _CanRotateDraggingItem(self, ...)
end

local _RotateDraggingItem = SnowmanDecoratingScreen.RotateDraggingItem
function SnowmanDecoratingScreen:RotateDraggingItem(delta, ...)
    local itemdata = self.dragitem.itemdata
    if self.dragitem and itemdata.custom_animation_num_rots then
        local num_rots = itemdata.custom_animation_num_rots
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
    local num_rots = self.dragitem.itemdata.custom_animation_num_rots
    if self.dragitem and num_rots then
        self.dragitem.flip = not self.dragitem.flip
        local rot = ((num_rots - self.dragitem.rot + 1) % num_rots) + 1
        self.dragitem.rot = rot
        SnowmanDecoratable.SnowmanDecorateCommon(self.dragitem.inst, self.dragitem.itemdata, self.dragitem.flip, self.dragitem.rot)
    else
        _FlipDraggingItem(self, ...)
    end
end
