local AddComponentPostInit = AddComponentPostInit
local GetModConfigData = GetModConfigData
GLOBAL.setfenv(1, GLOBAL)

local snowman_utils = require("snowman_utils")
local SetSnowmanSkin = snowman_utils.SetSnowmanSkin
local GetEventCallbacks = snowman_utils.GetEventCallbacks
local SnowmanDecoratable = require("components/snowmandecoratable")

local STACK_IDS = SnowmanDecoratable.STACK_IDS
local STACK_DATA = SnowmanDecoratable.STACK_DATA

if GetModConfigData("ModifySnowmanDecorateLimit") then
    TUNING.SNOWMAN_MAX_DECOR = { 9999, 9999, 9999 }
end

local ModifySnowmanStackHeight = GetModConfigData("ModifySnowmanStackHeight") or 6
if ModifySnowmanStackHeight > 6 then
    GlassicAPI.UpvalueUtil.SetUpvalue(SnowmanDecoratable.CanStack, "MAX_STACK_HEIGHT", ModifySnowmanStackHeight)
end

local function OnSkinsChanged(inst) -- for open snowmandecoratingscreen
    local value = inst.components.snowmandecoratable.stackskins:value()
    inst.components.snowmandecoratable.stackskins:set_local(value)
    inst.components.snowmandecoratable.stackskins:set(value)
end

AddComponentPostInit("snowmandecoratable", function(self, inst)
    self.decors = {}
    self.stackskins = net_string(inst.GUID, "snowmandecoratable.stackskins", "stacksdirty")

    if not self.ismastersim then
        local OnDecorDataDirty_Client = GetEventCallbacks(inst, "decordatadirty")
        inst:RemoveEventCallback("decordatadirty", OnDecorDataDirty_Client)

        local OnStacksDirty_Client = GetEventCallbacks(inst, "stacksdirty")
        inst:RemoveEventCallback("stacksdirty", OnStacksDirty_Client)
    else
        inst:ListenForEvent("decordatadirty", function()
            inst.components.snowmandecoratable:DoRefreshDecorData()
        end)
        -- inst:ListenForEvent("decordatadirty", function()
        --     inst.components.snowmandecoratable:OnStacksChanged("clientsync")
        -- end)
    end

    self.inst:ListenForEvent("onskinschanged", OnSkinsChanged)
end)

function SnowmanDecoratable:SetStackSkins(stackskins)
    self.stackskins:set(ZipAndEncodeString(stackskins))
end

function SnowmanDecoratable:GetStackSkins()
    return DecodeAndUnzipString(self.stackskins:value()) or {}
end

function SnowmanDecoratable:Unstack(isdestroyed)
    if not self.ismastersim then
        return
    end
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local pt = self.inst:GetPosition()
    local stackskins = self:GetStackSkins()
    for i, v in ipairs(self.stacks:value()) do
        local skin_type = stackskins[i]
        if v == STACK_IDS.small then
            local item = self:DoDropItem("snowball_item", x, z)
            SetSnowmanSkin(item, skin_type)
        else
            local stackdata = STACK_DATA[v]
            if stackdata then
                if isdestroyed then
                    local snowman = SpawnPrefab("snowman")
                    SetSnowmanSkin(snowman, skin_type)
                    snowman:SetSize(stackdata.name)
                    snowman.Transform:SetPosition(x, 0, z)
                    snowman.components.workable:Destroy(self.inst)
                else
                    local item = self:DoDropItem("snowman", x, z, stackdata.name)
                    SetSnowmanSkin(item, skin_type)
                end
            end
        end
    end
    if self.basesize:value() == STACK_IDS.small then
        local item = self:DoDropItem("snowball_item", x, z)
        SetSnowmanSkin(item, self.inst.skin_type)
        self.inst:Remove()
    else
        local empty = {}
        self.stacks:set(empty)
        self.stackoffsets:set(empty)
        self:OnStacksChanged("unstack")
        if self.inst.components.inventoryitem then
            if self.inst.components.heavyobstaclephysics then
                self.inst.components.heavyobstaclephysics:ForceDropPhysics()
            end
            self.inst.components.inventoryitem:DoDropPhysics(x, 0, z, true, 0.5)
        end
    end
end

local _Stack = SnowmanDecoratable.Stack
function SnowmanDecoratable:Stack(doer, obj, ...)
    if not self.ismastersim or not obj.components.snowmandecoratable then
        return
    end

    local stackskins = self:GetStackSkins()
    table.insert(stackskins, obj.skin_type or "")
    self:SetStackSkins(stackskins)
    -- local data, references = obj:GetPersistData()
    _Stack(self, doer, obj, ...)
end

local _OnSave = SnowmanDecoratable.OnSave
function SnowmanDecoratable:OnSave(...)
    local data, references = _OnSave(self, ...)
    data = data or {}
    data.stackskins = self.stackskins:value()
    return data, references
end

local _OnLoad = SnowmanDecoratable.OnLoad
function SnowmanDecoratable:OnLoad(data, newents, ...)
    if data then
        self.stackskins:set(data.stackskins or "")
    end
    return _OnLoad(self, data, newents, ...)
end

function SnowmanDecoratable.SnowmanDecorateCommon(inst, itemdata, flip, rot)
    if itemdata.light then
        if not inst.Light then
            inst.entity:AddLight()
        end
        if itemdata.light.falloff ~= nil then
            inst.Light:SetFalloff(itemdata.light.falloff)
        end
        if itemdata.light.intensity ~= nil then
            inst.Light:SetIntensity(itemdata.light.intensity)
        end
        if itemdata.light.radius ~= nil then
            inst.Light:SetRadius(itemdata.light.radius)
        end
        if itemdata.light.radius ~= nil then
            inst.Light:SetRadius(itemdata.light.radius)
        end
        if itemdata.light.colour ~= nil then
            inst.Light:SetColour((itemdata.light.colour / 255):Get())
        end

        inst.Light:Enable(true)
    end

    inst.AnimState:SetBank(itemdata.bank)
    inst.AnimState:SetBuild(itemdata.build)

    if itemdata.mult_colour then
        inst.AnimState:SetMultColour(unpack(itemdata.mult_colour))
    end
    if itemdata.use_point_filtering then
        inst.AnimState:UsePointFiltering(true)
    end
    if itemdata.bloome_ffect then
        inst.AnimState:SetBloomEffectHandle(itemdata.bloome_ffect)
    end

    local animation = itemdata.anim..(flip and itemdata.canflip and "_flip" or "")
    if itemdata.custom_animation_num_rots then
        animation = animation .. "_" .. (rot - 1)
        inst.AnimState:Resume()
        inst.AnimState:PlayAnimation(animation, true)
    else
        inst.AnimState:PlayAnimation(animation)
        inst.AnimState:SetFrame(rot - 1)
        inst.AnimState:Pause()
    end

    if itemdata.fn then
        itemdata.fn(inst, itemdata)
    end
end

local _ApplyDecor = SnowmanDecoratable.ApplyDecor
local _CreateDecor, i, _DoDecor = GlassicAPI.UpvalueUtil.GetUpvalue(_ApplyDecor, "_DoDecor.CreateDecor")
local function CreateDecor(itemdata, rot, flip, ...)
    local inst = SpawnPrefab("snowman_decorate")
    SnowmanDecoratable.SnowmanDecorateCommon(inst, itemdata, flip, rot)
    return inst
end
debug.setupvalue(_DoDecor, i, CreateDecor)

SnowmanDecoratable.ApplyDecor = function(decordata, decors, basesize, stacks, stackoffsets, owner, ...)
    _ApplyDecor(decordata, decors, basesize, stacks, stackoffsets, owner, ...)
    for i, decor in ipairs(decors) do
        decor:AttachHighLightParent(owner)
    end
    owner.highlightchildren = {}
end
GlassicAPI.UpvalueUtil.SetUpvalue(SnowmanDecoratable.DoRefreshDecorData, "ApplyDecor", SnowmanDecoratable.ApplyDecor)
