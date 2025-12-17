if not SnowmanConfig.MoreFunSnowball then
    return
end

GLOBAL.setfenv(1, GLOBAL)

local NON_COLLAPSIBLE_TAGS = {"stump", "flying", "shadow", "playerghost", "NOCLICK", "INLIMBO"}

local function GetDestByAngle(start_pos, angle, dist)
    local x,_,z = start_pos:Get()
    local theta = angle*DEGREES
    local x1 = x + math.cos(theta)*dist
    local z1 = z - math.sin(theta)*dist
    local dest_pos = Vector3(x1,0,z1)
    return dest_pos, dest_pos-start_pos
end

local Pushable = require("components/pushable")
local _StopPushing = Pushable.StopPushing

function Pushable:StopImmediately(doer)
    if self.stop_task then
        self.stop_task:Cancel()
        self.stop_task = nil
    end

    _StopPushing(self, doer)
    self:SetOverridePushingSpeed(nil)
end

function Pushable:StopPushing(doer)
    if not doer then
        self:StopImmediately()
    else
        if not self.stop_task then
            -- 脱手后延迟1秒钟结束滚动
            self.stop_task = self.inst:DoTaskInTime(1, function()
                self.stop_task = nil
                -- StopPushing会误触发，需要二次检测：玩家没有在推动 或 玩家不在附近
                if not (self.doer and self.doer.sg and self.doer.sg:HasStateTag("pushing_walk") and self.doer:IsValid())
                    or (self.maxdist and not self.inst:IsNear(self.doer, self.doer:GetPhysicsRadius(0) + self.maxdist)) then
                    self:StopImmediately(doer)
                end
            end)
        end
    end
end

local _OnUpdate = Pushable.OnUpdate
function Pushable:OnUpdate(dt)
    -- 覆盖雪球滚动速度
    local original_speed = self.speed
    self.speed = self.overridespeed or self.speed
    _OnUpdate(self, dt)
    self.speed = original_speed

    -- 根据玩家到雪球的连线修改雪球方向
    local pos = self.inst:GetPosition()
    local angle = self.inst.Transform:GetRotation()
    if self.doer then
        angle = self.doer:GetAngleToPoint(pos:Get())
        self.inst.Transform:SetRotation(angle)
    end

    -- 处理碰撞
    local size = self.inst.components.snowmandecoratable:GetSize()
    if size ~= "small" then
        self:HandleCollision(pos, angle)
    end
end

function Pushable:HandleCollision(pos, angle)
    -- 检测雪球前方范围是否有可碰撞的实体
    local forwardpos = GetDestByAngle(pos, angle, (self.mindist or 0) + 0.5)
    local ents = TheSim:FindEntities(forwardpos.x, 0, forwardpos.z, 0.85, nil, NON_COLLAPSIBLE_TAGS, {"blocker", "_health"})
    for i, ent in ipairs(ents) do
        local r = ent:GetPhysicsRadius(0)
        -- 只碰撞有一定物理半径 或 有生命的实体
        if ent ~= self.inst and (r > 0.2 or ent.components.health) then
            if self.doer then
                local str = "ANNOUNCE_I_MESSED_UP"
                if ent.components.health and not ent.components.health:IsDead() then
                    if ent.components.combat then
                        ent.components.combat:GetAttacked(self.doer, TUNING.SNOWBALL_DAMAGE)
                    end
                    str = "ANNOUNCE_TRY_MY_SNOWBALL"
                end
                if ent.components.freezable then
                    ent.components.freezable:AddColdness(4, 1)
                end
                if ent.components.workable then
                    ent.components.workable:Destroy(self.doer)
                end
                if self.doer.components.talker then
                    self.doer.components.talker:Say(GetString(self.doer, str))
                end
            end
            self:StopImmediately()
            if self.inst.components.workable then
                self.inst.components.workable:Destroy(self.inst)
            end
            break
        end
    end
end

function Pushable:SetOverridePushingSpeed(speed)
    self.overridespeed = speed
end

function Pushable:GetOverridePushingSpeed()
    return self.overridespeed or self.speed
end
