if SnowmanConfig.MoreFunSnowball ~= true then
    return
end

local AddPlayerPostInit = AddPlayerPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPlayerPostInit(function(inst)
    local talker = inst.components.talker
    if not talker then return end

    local old_Say = talker.Say
    function talker:Say(str, ...)
        if str == GetString(inst, "ANNOUNCE_SNOWBALL_TOO_BIG") then
            str = STRINGS.CHARACTERS.GENERIC.BIG_SNOWBALL_IS_COMMING
        end
        old_Say(self, str, ...)
    end
end)
