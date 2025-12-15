local modimport = modimport
local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)

local loc = require("languages/loc")

local function DoTranslate()
    local language = loc.GetLanguage and loc.GetLanguage() or nil
    if language == LANGUAGE.CHINESE_S or language == LANGUAGE.CHINESE_S_RAIL then
        modimport("scripts/localization/snowman_strings_zh")
    else
        modimport("scripts/localization/snowman_strings_en")
    end
end

DoTranslate()
AddSimPostInit(DoTranslate)
