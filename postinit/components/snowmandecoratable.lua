local AddComponentPostInit = AddComponentPostInit
local GetModConfigData = GetModConfigData
GLOBAL.setfenv(1, GLOBAL)

local snowman_utils = require("snowman_utils")
local SnowmanSkins = snowman_utils.SnowmanSkins
local GetEventCallbacks = snowman_utils.GetEventCallbacks
local SnowmanDecoratable = require("components/snowmandecoratable")

if GetModConfigData("ModifySnowmanDecorateLimit") then
    TUNING.SNOWMAN_MAX_DECOR = { 9999, 9999, 9999 }
end

local ModifySnowmanStackHeight = GetModConfigData("ModifySnowmanStackHeight") or 6
if ModifySnowmanStackHeight > 6 then
    GlassicAPI.UpvalueUtil.SetUpvalue(SnowmanDecoratable.CanStack, "MAX_STACK_HEIGHT", ModifySnowmanStackHeight)
end

AddComponentPostInit("snowmandecoratable", function(self, inst)
    self.decors = {}
    self.stackskins = {}

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
end)

function SnowmanDecoratable:GetStackSkins()
    return self.stackskins
end

local _Stack = SnowmanDecoratable.Stack
function SnowmanDecoratable:Stack(doer, obj, ...)
	if not self.ismastersim or not obj.components.snowmandecoratable then
		return
    end

    table.insert(self.stackskins, obj.skin_type or "")
    -- local data, references = obj:GetPersistData()
    _Stack(self, doer, obj, ...)
end

local _OnSave = SnowmanDecoratable.OnSave
function SnowmanDecoratable:OnSave(...)
    local data, references = _OnSave(self, ...)
    data = data or {}
    data.stackskins = self.stackskins
    return data, references
end

local _OnLoad = SnowmanDecoratable.OnLoad
function SnowmanDecoratable:OnLoad(data, newents, ...)
    if data then
        self.stackskins = data.stackskins or {}
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

local _CreateDecor, i, _DoDecor = GlassicAPI.UpvalueUtil.GetUpvalue(SnowmanDecoratable.ApplyDecor, "_DoDecor.CreateDecor")
local function CreateDecor(itemdata, rot, flip, ...)
    local inst = SpawnPrefab("snowman_decorate")
    SnowmanDecoratable.SnowmanDecorateCommon(inst, itemdata, flip, rot)
    return inst
end
debug.setupvalue(_DoDecor, i, CreateDecor)
