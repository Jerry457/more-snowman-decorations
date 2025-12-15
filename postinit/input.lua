if not SnowmanConfig.MoreFunSnowball then
    return
end

GLOBAL.setfenv(1, GLOBAL)
-- 这个写的不好，获取鼠标位置应该考虑写在其他地方

local _OnUpdate = TheInput.OnUpdate
function TheInput:OnUpdate()
    _OnUpdate(self)

    if ThePlayer == nil or ThePlayer.components.playercontroller == nil then
        return
    end

    local LEFT, RIGHT = CONTROL_PRIMARY, CONTROL_SECONDARY
    local left, right = TheSim:GetAnalogControl(LEFT), TheSim:GetAnalogControl(RIGHT)

    if right == 1 and not self:GetHUDEntityUnderMouse() then

        local x, y, z = TheSim:ProjectScreenPos(TheSim:GetPosition())
        ThePlayer.mouse_world_pos = Vector3(x, 0, z)

        if TheNet:GetIsClient() then
            SendModRPCToServer(MOD_RPC["pushing_walk"]["mouse_world_pos"],x,z)
        end
    end
end
