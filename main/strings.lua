local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

local loc = require("languages/loc")

local function DoTranslate()
    local language = loc.GetLanguage and loc.GetLanguage() or nil
    if language == LANGUAGE.CHINESE_S or language == LANGUAGE.CHINESE_S_RAIL then
        require("localization/snowman_strings_zh")
    else
        require("localization/snowman_strings_en")
    end
end

DoTranslate()
