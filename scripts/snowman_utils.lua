local SnowmanDecoratable = require("components/snowmandecoratable")

local SnowmanPrefabs = {
    "snowman",
    "snowball_item",
    "snowman_stack",
}

local SnowmanSkins = {
    "dungball",
}

local function SetSnowmanSkin(ent, skin_type)
    if skin_type and skin_type ~= "" then
        local skinname = ent.prefab .. "_" ..  skin_type
        TheSim:ReskinEntity(ent.GUID, skinname, skinname)
    end
end

local function GetEventCallbacks(inst, event, source, source_file, test_fn)
    source = source or inst

    if not inst.event_listening[event] or not inst.event_listening[event][source] then
        return
    end

    for _, fn in ipairs(inst.event_listening[event][source]) do
        if source_file then
            local info = debug.getinfo(fn, "S")
            if info and (info.source == source_file) and (not test_fn or test_fn(fn)) then
                return fn
            end
        elseif (not test_fn or test_fn(fn)) then
            return fn
        end
    end
end


return {
    SnowmanPrefabs = SnowmanPrefabs,
    SnowmanSkins = SnowmanSkins,
    SetSnowmanSkin = SetSnowmanSkin,
    GetEventCallbacks = GetEventCallbacks,
}
