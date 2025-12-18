local SPRINT_TRAIL_FX_POOL = {}
local SPRINT_TRAIL_FX_COUNT = 0 --live count, excludes ones in pool
local SPRINT_TRAIL_FX_POOL_CLEANUP_TASK = nil

local IDENTIFIER = "SnowMan"


local COLOR_VAL = IDENTIFIER.."_sprint_trail_colour"
local ALPHA_VAL = IDENTIFIER.."_trail_alpha_mult"
local ONUPDATE_TASK = IDENTIFIER.."_sprinttrail_onudpate"
local PREDICT_VAL = IDENTIFIER.."_predict_sprint_trail"
local HAS_TRAIL_VAL = IDENTIFIER.."_has_sprint_trail"
local HAS_TRAIL_DIRTY_EVENT = IDENTIFIER.."has_sprint_trail_dirty"
local DISABLE_TASK = IDENTIFIER.."_disablesprinttrailtask"
local ENABLE_FN = IDENTIFIER.."EnableSprintTrail"
local UPDATING_VAL = IDENTIFIER.."_updatingsprinttrail"

local function IncSprintTrailFx()
	if SPRINT_TRAIL_FX_POOL_CLEANUP_TASK then
		SPRINT_TRAIL_FX_POOL_CLEANUP_TASK:Cancel()
		SPRINT_TRAIL_FX_POOL_CLEANUP_TASK = nil
	end
	SPRINT_TRAIL_FX_COUNT = SPRINT_TRAIL_FX_COUNT + 1
end

local function DumpSprintTrailFxPool()
	for i = 1, #SPRINT_TRAIL_FX_POOL do
		SPRINT_TRAIL_FX_POOL[i]:Remove()
		SPRINT_TRAIL_FX_POOL[i] = nil
	end
end

local function DecSprintTrailFx()
	SPRINT_TRAIL_FX_COUNT = SPRINT_TRAIL_FX_COUNT - 1
	if SPRINT_TRAIL_FX_COUNT <= 0 then
		if SPRINT_TRAIL_FX_POOL_CLEANUP_TASK == nil then
			SPRINT_TRAIL_FX_POOL_CLEANUP_TASK = TheWorld:DoTaskInTime(30, DumpSprintTrailFxPool)
		else
			assert(false) --sanity check
		end
	end
end

local function CreateSprintTrailFx(inst)
	local fx = CreateEntity()

	fx:AddTag("FX")
	fx:AddTag("NOCLICK")
	--[[Non-networked entity]]
	fx.entity:SetCanSleep(false)
	fx.persists = false

	fx.entity:AddTransform()
	fx.entity:AddAnimState()

	fx.Transform:SetFourFaced()

	fx.AnimState:SetBank("wilson")
	fx.AnimState:UsePointFiltering(true)
    fx.AnimState:SetSortOrder(0)
	fx.AnimState:SetScale(1.035, 1.035)

	fx.AnimState:Hide("ARM_carry")

	fx:AddComponent("updatelooper")

	return fx
end

local function GetSprintTrailFx(inst)

	local fx = table.remove(SPRINT_TRAIL_FX_POOL)

	if fx and fx:IsValid() then
		fx:ReturnToScene()
	else
		fx = CreateSprintTrailFx(inst)
	end
    fx.AnimState:SetAddColour(unpack(inst[COLOR_VAL]))

    if inst.AnimState:GetSkinBuild() == "" then
        fx.AnimState:SetBuild(inst.AnimState:GetBuild())
    else
        fx.AnimState:SetBuild(inst.prefab)
    end

	--Reset the entity
	fx.a = nil
	fx:Hide()

	fx.OnRemoveEntity = DecSprintTrailFx --This is just in case somehow something else removes us
	IncSprintTrailFx()

	return fx
end

--------------------------------------------------------------------------
local TRAIL_Y_OFFSET = -0.04

--V2C: Keeping it parented is the only way to guarantee the facing matches.
local function SprintTrailFx_PostUpdate(fx)
	local inst = fx.entity:GetParent()
	if inst then
		fx.Transform:SetPosition(inst.entity:WorldToLocalSpace(fx.x, fx.y+TRAIL_Y_OFFSET, fx.z))
		fx.Transform:SetRotation(fx.rot - inst.Transform:GetRotation())
		fx.AnimState:MakeFacingDirty()
	end
end

local TRAIL_LENGTH = 8
local TRAIL_ALPHA = 0.3
local TRAIL_FADE_DELTA = TRAIL_ALPHA / TRAIL_LENGTH

local function SprintTrailFx_OnUpdate(fx)
	if fx.a == nil then
		fx.a = TRAIL_ALPHA
		fx:Show()
	else
		fx.a = fx.a - TRAIL_FADE_DELTA
	end
	if fx.a > 0 then
		fx.AnimState:SetMultColour(1, 1, 1, fx.a * fx.alpha_mult)
	else
		--Return to pool
		fx.components.updatelooper:RemovePostUpdateFn(SprintTrailFx_PostUpdate)
		fx.components.updatelooper:RemoveOnUpdateFn(SprintTrailFx_OnUpdate)
		fx.OnRemoveEntity = nil
		fx:RemoveFromScene()
		table.insert(SPRINT_TRAIL_FX_POOL, fx)
		DecSprintTrailFx()
	end
end

-- runs on clients too
local function OnUpdateSprintTrail(inst, dt)
	local bank, anim = inst.AnimState:GetHistoryData()
	local arm_carry = inst.replica.inventory and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if anim and inst.entity:IsVisible() then
		local fx = GetSprintTrailFx(inst)
		fx.entity:SetParent(inst.entity)
		fx.AnimState:PlayAnimation(anim)
		if arm_carry then
			fx.AnimState:Show("ARM_carry")
			fx.AnimState:Hide("ARM_normal")
		else
			fx.AnimState:Show("ARM_normal")
			fx.AnimState:Hide("ARM_carry")
		end
		fx.AnimState:SetTime(inst.AnimState:GetCurrentAnimationTime())
		fx.AnimState:Pause()
		fx.x, fx.y, fx.z = inst.Transform:GetWorldPosition()
		fx.alpha_mult = inst[ALPHA_VAL] or 1
		fx.rot = inst.Transform:GetRotation()
		fx.components.updatelooper:AddPostUpdateFn(SprintTrailFx_PostUpdate)
		fx.components.updatelooper:AddOnUpdateFn(SprintTrailFx_OnUpdate)
	end
end

local function SprintTrail_OnEntitySleep(inst)
	if inst[ONUPDATE_TASK] then
		inst[ONUPDATE_TASK] = nil
		inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateSprintTrail)
	end
end

local function SprintTrail_OnEntityWake(inst)
	if not inst[ONUPDATE_TASK] then
		inst[ONUPDATE_TASK] = true
		inst.components.updatelooper:AddOnUpdateFn(OnUpdateSprintTrail)
	end
end

local function OnHasSprintTrail(inst)
	if inst[PREDICT_VAL] or inst[HAS_TRAIL_VAL]:value() then
		if not inst[UPDATING_VAL] then
			if inst.components.updatelooper == nil then
				inst:AddComponent("updatelooper")
			end
			if TheWorld.ismastersim then
				inst:ListenForEvent("entitysleep", SprintTrail_OnEntitySleep)
				inst:ListenForEvent("entitywake", SprintTrail_OnEntityWake)
				if not inst:IsAsleep() then
					SprintTrail_OnEntityWake(inst)
				end
			else
				inst.components.updatelooper:AddOnUpdateFn(OnUpdateSprintTrail)
			end
			inst[UPDATING_VAL] = true
		end
	elseif inst[UPDATING_VAL] then
		if TheWorld.ismastersim then
			inst:RemoveEventCallback("entitysleep", SprintTrail_OnEntitySleep)
			inst:RemoveEventCallback("entitywake", SprintTrail_OnEntityWake)
			SprintTrail_OnEntitySleep(inst)
		else
			inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateSprintTrail)
		end
		inst[UPDATING_VAL] = false
	end
end

local function OnDisableSprintTask_Server(inst)
	inst[DISABLE_TASK] = nil
	inst[HAS_TRAIL_VAL]:set(false)
	if not TheNet:IsDedicated() then
		OnHasSprintTrail(inst)
	end
end

local function EnableSprintTrail_Server(inst, enable)
	if enable then
		if inst[DISABLE_TASK] then
			inst[DISABLE_TASK]:Cancel()
			inst[DISABLE_TASK] = nil
		elseif not inst[HAS_TRAIL_VAL]:value() then
			inst[HAS_TRAIL_VAL]:set(true)
			if not TheNet:IsDedicated() then
				OnHasSprintTrail(inst)
			end
		end
	elseif inst[HAS_TRAIL_VAL]:value() and inst[DISABLE_TASK] == nil then
		inst[DISABLE_TASK] = inst:DoStaticTaskInTime(0, OnDisableSprintTask_Server)
	end
end

--------------------------------------------------------------------------
--For prediction

local function OnDisableSprintTask_Client(inst)
	inst[DISABLE_TASK] = nil
	inst[PREDICT_VAL] = false
	OnHasSprintTrail(inst)
end

local function EnableSprintTrail_Client(inst, enable)
	if enable then
		if inst[DISABLE_TASK] then
			inst[DISABLE_TASK]:Cancel()
			inst[DISABLE_TASK] = nil
		elseif not inst[PREDICT_VAL] then
			inst[PREDICT_VAL] = true
			OnHasSprintTrail(inst)
		end
	elseif inst[PREDICT_VAL] and inst[DISABLE_TASK] == nil then
		inst[DISABLE_TASK] = inst:DoStaticTaskInTime(0, OnDisableSprintTask_Client)
	end
end

local function OnEnableMovementPrediction_Client(inst, enable)
	if not enable and inst[PREDICT_VAL] then
		if inst[DISABLE_TASK] then
			inst[DISABLE_TASK]:Cancel()
			inst[DISABLE_TASK] = nil
		end
		inst[PREDICT_VAL] = nil
		OnHasSprintTrail(inst)
	end
end

local function SetUpSprintTrail(inst, colour)
    inst[COLOR_VAL] = colour or {1, 1, 1, 0}

    if inst[HAS_TRAIL_VAL] then
        return
    end
	inst[HAS_TRAIL_VAL] = net_bool(inst.GUID, HAS_TRAIL_VAL, HAS_TRAIL_DIRTY_EVENT)

	if TheWorld.ismastersim then
		inst[ENABLE_FN] = EnableSprintTrail_Server
	else
		inst:ListenForEvent(HAS_TRAIL_DIRTY_EVENT, OnHasSprintTrail)
		inst:ListenForEvent("enablemovementprediction", OnEnableMovementPrediction_Client)
		inst[ENABLE_FN] = EnableSprintTrail_Client
	end
end

local function SetTrailAlphaMult(inst, mult)
	inst[ALPHA_VAL] = mult or 1
end

local function SetTrailColour(inst, colour)
	inst[COLOR_VAL] = colour or {1, 1, 1, 0}
end

return {
	SetUpSprintTrail = SetUpSprintTrail,
	SetTrailAlphaMult = SetTrailAlphaMult,
    SetTrailColour = SetTrailColour,
}
