local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local SpawnSnowmanHook = require("snowman_utils").SpawnSnowmanHook

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_object", inst.GUID, "snowball")
    else
        owner.AnimState:OverrideSymbol("swap_object", "snowball", "swap_object")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

AddPrefabPostInit("snowball_item", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.components.equippable:SetOnEquip(OnEquip)

    local _OnHit = inst.components.projectile.onhit
    inst.components.projectile.onhit = function(inst, ...)
        return SpawnSnowmanHook(inst.skin_type, _OnHit, inst, ...)
    end

	local OnStartPushing = inst.components.pushable.onstartpushingfn
    inst.components.pushable.onstartpushingfn = function(inst, ...)
        return SpawnSnowmanHook(inst.skin_type, OnStartPushing, inst, ...)
    end
end)
