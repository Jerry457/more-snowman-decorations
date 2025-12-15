if SnowmanConfig.MoreFunSnowball ~= true then
    return
end

local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

local function SetWorldVelocity(inst, angle, velocity, vy)
    vy = vy or 0
    local face_angle = inst.Transform:GetRotation()
    local theta = (angle - face_angle)*DEGREES
    local vx = velocity * math.cos(theta)
    local vz = velocity * (-math.sin(theta))
    inst.Physics:SetMotorVel(vx, vy, vz)
end

local function GetDestByAngle(start_pos, angle, dist)
    local x,_,z = start_pos:Get()
    local theta = angle*DEGREES
    local x1 = x + math.cos(theta)*dist
    local z1 = z - math.sin(theta)*dist
    local dest_pos = Vector3(x1,0,z1)
    return dest_pos, dest_pos-start_pos
end

local function GetRotationDirection(start_angle, dest_angle)
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

local function DoRunSounds(inst)
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
        if target == nil or target.components.pushable == nil then
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
            local clockwise = GetRotationDirection(face_angle, mouse_angle)
            if math.cos((mouse_angle-face_angle)*DEGREES) > 0.99 then
                face_angle = mouse_angle
            else
                face_angle = face_angle + 4*clockwise
            end
            inst.Transform:SetRotation(face_angle)
            local target_pos = target:GetPosition()
            local mindist = inst:GetPhysicsRadius(0) + (target.components.pushable.mindist or 0)
            local dest_pos = GetDestByAngle(target_pos, face_angle, -mindist)
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
            SetWorldVelocity(inst, walk_angle, speed*extra_speedmult)
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
