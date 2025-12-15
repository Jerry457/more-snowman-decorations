if SnowmanConfig.MoreFunSnowball ~= true then
    return
end

local AddClassPostConstruct = AddClassPostConstruct
GLOBAL.setfenv(1, GLOBAL)

AddClassPostConstruct("widgets/hoverer",function(self)

    local old_SetString = self.secondarytext.SetString

    local old_OnUpdate = self.OnUpdate
    self.OnUpdate = function(self)
        local ispushingsnowball
        if TheWorld.ismastersim then
            ispushingsnowball = ThePlayer and ThePlayer.sg and ThePlayer.sg.currentstate and ThePlayer.sg.currentstate.name == "pushing_walk"
        else
            ispushingsnowball = ThePlayer and ThePlayer.player_classified and ThePlayer.player_classified.currentstate and ThePlayer.player_classified.currentstate:value() == hash("pushing_walk")
        end
        if ispushingsnowball then
            self.text:Hide()
            self.secondarytext:Show()
            self.secondarytext.SetString = function() end
            local str = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY)..": "..GetActionString(ACTIONS.START_PUSHING.id, "ROLL")

            self.secondarytext.string = str
            self.secondarytext.inst.TextWidget:SetString(str or "")
            return
        else
            self.secondarytext.SetString = old_SetString
        end
        return old_OnUpdate(self)
    end
end)
