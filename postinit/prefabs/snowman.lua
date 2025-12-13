local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local SetSnowmanSkin = require("snowman_utils").SetSnowmanSkin
local SnowmanDecoratable = require("components/snowmandecoratable")

local CheckLiftAndPushable
local CheckWaxable
local RefreshPhysicsSize
local TryHitAnim
local CreateStack

local function OnStacksChanged(inst, stacks, stackoffsets, reason)
    local basesize = inst.components.snowmandecoratable:GetSize()
    local stackskins = inst.components.snowmandecoratable:GetStackSkins()
    if TheWorld.ismastersim then
        CheckLiftAndPushable(inst)
        CheckWaxable(inst)
        if reason == "addstack" then
            local laststackid = SnowmanDecoratable.STACK_IDS[basesize]
            local laststackdata = SnowmanDecoratable.STACK_DATA[laststackid]
            if laststackdata then
                local height, offset = 0, 0
                for i, v in ipairs(stacks) do
                    local stackdata = SnowmanDecoratable.STACK_DATA[v]
                    if stackdata then
                        height = height + laststackdata.heights[v]
                        offset = SnowmanDecoratable.CalculateStackOffset(stackdata.r, stackoffsets[i])
                        laststackid = v
                        laststackdata = stackdata
                    end
                end
                local fx = SpawnPrefab("snowman_debris_fx")
                fx.AnimState:SetBuild(stackskins[#stackskins])
                fx.AnimState:PlayAnimation("debris_" .. laststackdata.name)
                fx.Follower:FollowSymbol(inst.GUID, "snowman_ball", offset, -height, 0)
            end
            TryHitAnim(inst)
            inst.SoundEmitter:PlaySound("meta5/snowman/place_snow")
        end
    -- end
    -- if not TheNet:IsDedicated() then
        local laststackid = SnowmanDecoratable.STACK_IDS[basesize]
        local laststackdata = SnowmanDecoratable.STACK_DATA[laststackid]
        if laststackdata then
            if inst.stacks == nil then
                inst.stacks = {}
            end
            if inst.highlightchildren == nil then
                inst.highlightchildren = {}
            end
            local height = 0
            local n = 1
            for i, v in ipairs(stacks) do
                local stackdata = SnowmanDecoratable.STACK_DATA[v]
                if stackdata then
                    height = height + laststackdata.heights[v]

                    local ent = inst.stacks[n]
                    if ent == nil then
                        ent = SpawnPrefab("snowman_stack")
                        ent:ListenForEvent("onskinschanged", function()
                            stackskins[i] = ent.skin_type or ""
                        end)
                        local userid = nil
                        SetSnowmanSkin(ent, stackskins[i])
                        ent.entity:SetParent(inst.entity)
                        local offset = SnowmanDecoratable.CalculateStackOffset(stackdata.r, stackoffsets[i])
                        ent.Follower:FollowSymbol(inst.GUID, "snowman_ball", offset, -height, 0, true)
                        inst.stacks[n] = ent
                        table.insert(inst.highlightchildren, ent)
                    end
                    ent.AnimState:PlayAnimation((v > laststackid and "stack_clean_" or "stack_") .. stackdata.name)

                    laststackid = v
                    laststackdata = stackdata
                    n = n + 1
                end
            end
            for i = n, #inst.stacks do
                local v = inst.stacks[i]
                table.removearrayvalue(inst.highlightchildren, v)
                v:Remove()
                inst.stacks[i] = nil
            end
        end
    end
    RefreshPhysicsSize(inst, basesize, stacks)
end

local function OnEquip(inst, owner)
    local skin_build = inst.AnimState:GetSkinBuild() or "snowball"
    owner.AnimState:OverrideSymbol("swap_body", skin_build, inst.components.symbolswapdata.symbol)
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

AddPrefabPostInit("snowman", function(inst)
    local _OnStacksChanged = inst.components.snowmandecoratable.onstackschangedfn
    CheckLiftAndPushable = GlassicAPI.UpvalueUtil.GetUpvalue(_OnStacksChanged, "CheckLiftAndPushable")
    CheckWaxable = GlassicAPI.UpvalueUtil.GetUpvalue(_OnStacksChanged, "CheckWaxable")
    RefreshPhysicsSize = GlassicAPI.UpvalueUtil.GetUpvalue(_OnStacksChanged, "RefreshPhysicsSize")
    TryHitAnim = GlassicAPI.UpvalueUtil.GetUpvalue(_OnStacksChanged, "TryHitAnim")
    CreateStack = GlassicAPI.UpvalueUtil.GetUpvalue(_OnStacksChanged, "CreateStack")
    inst.components.snowmandecoratable.onstackschangedfn = OnStacksChanged

    if not TheWorld.ismastersim then
        return
    end

    inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
end)
