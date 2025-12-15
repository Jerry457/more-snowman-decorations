
AddModRPCHandler("pushing_walk", "mouse_world_pos", function(player,x,z)
    if not (checknumber(x) and checknumber(z)) then
        return
    end
    player.mouse_world_pos = Vector3(x, 0, z)
end)
