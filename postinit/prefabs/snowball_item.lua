local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local SpawnSnowmanHook = require("snowman_utils").SpawnSnowmanHook

AddPrefabPostInit("snowball_item", function(inst)
    if not TheWorld.ismastersim then
        return
    end

	local OnStartPushing = inst.components.pushable.onstartpushingfn
    inst.components.pushable.onstartpushingfn = function(...)
        SpawnSnowmanHook(inst.skin_type, OnStartPushing, ...)
    end
end)
