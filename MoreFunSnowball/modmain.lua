GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local locale = LOC.GetLocaleCode()
local chs = locale == "zh" or locale == "zhr"

local old_OnUpdate = TheInput.OnUpdate
function TheInput:OnUpdate()
    old_OnUpdate(self)

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

AddModRPCHandler("pushing_walk", "mouse_world_pos", function(player,x,z)
    if not (checknumber(x) and checknumber(z)) then
        return
    end
    player.mouse_world_pos = Vector3(x, 0, z)
end)

local function set_velocity_world_coordinate(inst, angle, velocity, vy)
    vy = vy or 0
    local face_angle = inst.Transform:GetRotation()
    local theta = (angle - face_angle)*DEGREES
    local vx = velocity * math.cos(theta)
    local vz = velocity * (-math.sin(theta))
    inst.Physics:SetMotorVel(vx, vy, vz)
end

local function get_dest_by_angular_dist(start_pos, angle, dist)
    local x,_,z = start_pos:Get()
    local theta = angle*DEGREES
    local x1 = x + math.cos(theta)*dist
    local z1 = z - math.sin(theta)*dist
    local dest_pos = Vector3(x1,0,z1)
    return dest_pos, dest_pos-start_pos
end

local function get_nearest_rotation_direction(start_angle, dest_angle)
    local included_theta = (dest_angle-start_angle)*DEGREES
    if math.sin(included_theta)>0 then
        return 1--顺时针
    else
        return -1--逆时针
    end
end

local function DoEquipmentFoleySounds(inst)
    for k, v in pairs(inst.components.inventory.equipslots) do
        if v.foleysound ~= nil then
            inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
        end
    end
end

local function DoFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    if inst.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
    end
end

local DoRunSounds = function(inst)
    if inst.sg.mem.footsteps > 3 then
        PlayFootstep(inst, .6, true)
    else
        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
        PlayFootstep(inst, 1, true)
    end
end

AddStategraphPostInit("wilson", function(sg)
    if sg.states["pushing_walk"] == nil then
        return
    end

    local old_onupdate = sg.states["pushing_walk"].onupdate
    sg.states["pushing_walk"].onupdate = function(inst, dt)
        local target = inst.sg.statemem.target
        if target == nil or not (target.prefab == "snowman" or target.prefab == "snowball_item") then
            return old_onupdate(inst, dt)
        end
        if not (target and target.components.pushable and target.components.pushable.doer == inst and target:IsValid()) then
            inst.sg.statemem.target = nil
            inst.AnimState:PlayAnimation("pushing_walk_idle_pst")
            inst.sg:GoToState("idle", true)
            return
        elseif inst.sg.statemem.canstop then
            if inst.sg.statemem.exitdelay then
                if inst.sg.statemem.exitdelay > dt then
                    inst.sg.statemem.exitdelay = inst.sg.statemem.exitdelay - dt
                else
                    inst.sg:GoToState("idle", true)
                end
                return
            elseif not (inst.components.playercontroller and
                        inst.components.playercontroller:IsAnyOfControlsPressed(
                            CONTROL_SECONDARY,
                            CONTROL_CONTROLLER_ALTACTION))
            then
                inst.AnimState:PlayAnimation("pushing_walk_idle_pst")
                inst.Physics:Stop()
                inst.sg:RemoveStateTag("jumping")
                DoRunSounds(inst)
                DoFoleySounds(inst)
                inst.sg.statemem.exitdelay = 3 * FRAMES
                return
            end
        end

        if inst.mouse_world_pos then
            local mouse_angle = inst:GetAngleToPoint(inst.mouse_world_pos:Get())
            local face_angle = inst.Transform:GetRotation()
            local clockwise = get_nearest_rotation_direction(face_angle, mouse_angle)
            if math.cos((mouse_angle-face_angle)*DEGREES) > 0.99 then
                face_angle = mouse_angle
            else
                face_angle = face_angle + 4*clockwise
            end
            inst.Transform:SetRotation(face_angle)
            local target_pos = target:GetPosition()
            local mindist = inst:GetPhysicsRadius(0) + (target.components.pushable.mindist or 0)
            local dest_pos = get_dest_by_angular_dist(target_pos, face_angle, -mindist)
            local distsq = inst:GetDistanceSqToPoint(dest_pos:Get())
            local extra_speedmult = 1
            if distsq < 1 then
                extra_speedmult = 1
            elseif distsq < 4 then
                extra_speedmult = 1.25
            else
                extra_speedmult = 1.5
            end
            local walk_angle = inst:GetAngleToPoint(dest_pos:Get())
            local speed = target.components.pushable:GetOverridePushingSpeed() * inst.sg.statemem.speedmult
            set_velocity_world_coordinate(inst, walk_angle, speed*extra_speedmult)
        end

        local size = target.components.snowmandecoratable:GetSize()
        if size ~= "small" then
            local old_speed = target.components.pushable:GetOverridePushingSpeed()
            if old_speed < 10 then
                target.components.pushable:SetOverridePushingSpeed(old_speed+0.03)
            end
        end

        for i = 11, 23, 12 do
            if inst.AnimState:GetCurrentAnimationFrame() == i then
                if inst.sg.statemem.lastfootstepframe ~= i then
                    inst.sg.statemem.lastfootstepframe = i
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
                break
            end
        end
    end
end)

local NON_COLLAPSIBLE_TAGS = {"stump", "flying", "shadow", "playerghost", "NOCLICK", "INLIMBO"}
TUNING.SNOWBALL_DAMAGE = 30

local function postinitfn(inst)
    local self = inst.components.pushable
    if not self then return end

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
        if size == "small" then
            return
        end
        -- 碰撞检测
        local forwardpos = get_dest_by_angular_dist(pos, angle, (self.mindist or 0) + 0.5)
        local ents = TheSim:FindEntities(forwardpos.x, 0, forwardpos.z, 0.85, nil, NON_COLLAPSIBLE_TAGS, {"blocker", "_health"})
        for i, ent in ipairs(ents) do
            local r = ent:GetPhysicsRadius(0)
            if ent ~= self.inst and (r > 0.2 or ent.components.health) then
                if self.doer then
                    local str = chs and "我把事情搞砸了！" or "I messed up!"
                    -- 生物造成伤害
                    if ent.components.health and not ent.components.health:IsDead() then
                        if ent.components.combat then
                            ent.components.combat:GetAttacked(self.doer, TUNING.SNOWBALL_DAMAGE)
                        end
                        str = chs and "来试试我的雪球！" or "Try my snowball!"
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

AddPrefabPostInit("snowman", postinitfn)
AddPrefabPostInit("snowball_item", postinitfn)

AddPlayerPostInit(function(inst)
    talker = inst.components.talker
    if not talker then return end
    local old_Say = talker.Say
    function talker:Say(str, ...)
        if str == GetString(inst, "ANNOUNCE_SNOWBALL_TOO_BIG") then
            str = chs and "大雪球来咯！" or "Big snowball is coming!"
        end
        old_Say(self, str, ...)
    end
end)


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
