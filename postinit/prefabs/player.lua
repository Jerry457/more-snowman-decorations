if not SnowmanConfig.MoreFunSnowball then
    return
end

local AddPlayerPostInit = AddPlayerPostInit
GLOBAL.setfenv(1, GLOBAL)
local TrailFns = require("snowman_trail")

AddPlayerPostInit(function(player)
    TrailFns.SetUpSprintTrail(player)

    -- 这里颜色可以考虑依据雪球皮肤来切换
    local colour = {0, 0, 1, 0}
    TrailFns.SetTrailColour(player, colour)
end)


