if SnowmanConfig.MoreFunSnowball ~= true then
    return
end

local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

TUNING.SNOWBALL_DAMAGE = 30 -- 移动到全局配置

local NON_COLLAPSIBLE_TAGS = {"stump", "flying", "shadow", "playerghost", "NOCLICK", "INLIMBO"}

local function GetDestByAngle(start_pos, angle, dist)
    local x,_,z = start_pos:Get()
    local theta = angle*DEGREES
    local x1 = x + math.cos(theta)*dist
    local z1 = z - math.sin(theta)*dist
    local dest_pos = Vector3(x1,0,z1)
    return dest_pos, dest_pos-start_pos
end

local function postinitfn(self)
    local old_StopPushing = self.StopPushing
    function self:StopPushing()
        if self.stop_task then
            return
        end

        self.stop_task = self.inst:DoTaskInTime(0.8, function()
            self.stop_task = nil
            if not (self.doer and self.doer.sg and self.doer.sg:HasStateTag("pushing_walk") and self.doer:IsValid()) or (self.maxdist and not self.inst:IsNear(self.doer, self.doer:GetPhysicsRadius(0) + self.maxdist)) then
                old_StopPushing(self)
                self:SetOverridePushingSpeed(nil)
            end
        end)
    end

    local old_OnUpdate = self.OnUpdate
    function self:OnUpdate(dt)

        local original_speed = self.speed
        self.speed = self.overridespeed or self.speed
        old_OnUpdate(self, dt)
        self.speed = original_speed

        local pos = self.inst:GetPosition()
        local angle = self.inst.Transform:GetRotation()
        if self.doer then
            angle = self.doer:GetAngleToPoint(pos:Get())
            self.inst.Transform:SetRotation(angle)
        end

        local size = self.inst.components.snowmandecoratable:GetSize()
        if size ~= "small" then
            self:HandleCollision(pos, angle)
        end
    end

    function self:HandleCollision(pos, angle)
        local forwardpos = GetDestByAngle(pos, angle, (self.mindist or 0) + 0.5)
        local ents = TheSim:FindEntities(forwardpos.x, 0, forwardpos.z, 0.85, nil, NON_COLLAPSIBLE_TAGS, {"blocker", "_health"})
        for i, ent in ipairs(ents) do
            local r = ent:GetPhysicsRadius(0)
            if ent ~= self.inst and (r > 0.2 or ent.components.health) then
                if self.doer then
                    local str = STRINGS.CHARACTERS.GENERIC.I_MESSED_UP
                    -- 生物造成伤害
                    if ent.components.health and not ent.components.health:IsDead() then
                        if ent.components.combat then
                            ent.components.combat:GetAttacked(self.doer, TUNING.SNOWBALL_DAMAGE)
                        end
                        str = STRINGS.CHARACTERS.GENERIC.TRY_MY_SNOWBALL
                    end
                    -- 冰冻
                    if ent.components.freezable then
                        ent.components.freezable:AddColdness(4, 1)
                    end
                    -- 可破坏物体
                    if ent.components.workable then
                        ent.components.workable:Destroy(self.doer)
                    end
                    -- 说话
                    self.doer.components.talker:Say(str)
                end
                -- 停止推动
                old_StopPushing(self)
                if self.stop_task then
                    self.stop_task:Cancel()
                    self.stop_task = nil
                end
                -- 摧毁自己
                if self.inst.components.workable then
                    self.inst.components.workable:Destroy(self.inst)
                end
                break
            end
        end
    end

    function self:SetOverridePushingSpeed(speed)
        self.overridespeed = speed
    end

    function self:GetOverridePushingSpeed()
        return self.overridespeed or self.speed
    end
end

AddComponentPostInit("pushable", postinitfn)
