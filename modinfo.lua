
local function en_zh(en, zh)  -- Other languages don't work
    return (locale == "zh" or locale == "zhr" or locale == "zht" or locale == "ch" or locale == "chs") and zh or en
end

-- This information tells other players more about the mod
version = "1.2.0" -- mod版本 上传mod需要两次的版本不一样
name = en_zh("Ultra Deluxe Snowball Overhaul", "超级豪华魔改版雪球")  ---mod名字
description = en_zh("V".. version ..
    "\n󰀔This mod completely revamps winter snowballs! \n󰀒Now you can decorate them with various in-game items, change their skins, and create your own unique snowball art. \n󰀐Build towering snowball structures or launch them at friends for chaotic fun—winter just got a lot more exciting!",
    "V" ..version.. "\n󰀔这个MOD对冬季的雪球进行了全面升级！\n󰀒现在，你可以用游戏中的各种物品自由装饰雪球，还能更换不同的皮肤，打造独一无二的雪球艺术。\n󰀐无论是堆叠成高塔，还是用来撞击朋友，都能让你的冬季冒险更加有趣！"
)  --mod描述
author = en_zh("Guto、jerry457、Jerusalem、王筱巫","Guto、jerry457、Jerusalem、王筱巫") --作者

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = ""

folder_name = folder_name or "workshop-"
if not folder_name:find("workshop-") then
    name = name .. "-dev"
end

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Compatible with Don't Starve Together
dst_compatible = true --兼容联机

-- Not compatible with Don't Starve
dont_starve_compatible = false --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

-- Character mods need this set to true
all_clients_require_mod = true
client_only_mod = false --所有人mod

priority = 9999

icon_atlas = "modicon.xml" --mod图标
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = {  --服务器标签
    "snowman"
}

local boolean_options = {
    {description = en_zh("Enable", "开启"), data = true},
    {description = en_zh("Disable", "关闭"), data = false},
}

local function get_numer_options(min, max, step)
    step = step or 1

    local options = {}
    local i = 1
    for num = min, max, step do
        options[i] = {description = num, data = num}
        i = i + 1
    end
    return options
end

configuration_options = {
    {
        name = "UnlimitSnowmanDecorate",
        label = en_zh("Remove Snowball Decoration Limit", "解除雪球装饰数量限制"),
        hover = en_zh("Place unlimited decorations on snowballs (bypasses vanilla game restrictions)", "允许在雪球上放置无限数量的装饰（突破原版游戏限制）"),
        options = boolean_options,
        default = true,
    },
    {
        name = "WaxedSnowmanCanStack",
        label = en_zh("Decorate/Stack Embalmed Snowball", "可以装饰、堆叠被防腐的雪球"),
        hover = en_zh("Allows decorating and stacking snowmen preserved with Embalming Spritz", "雪球被使用了防腐喷雾后，它将不会在冬季结束后融化，并且你仍然能够装饰或者堆叠它"),
        options = boolean_options,
        default = true,
    },
    {
        name = "SnowmanStackHeight",
        label = en_zh("Max Snowball Stack Height", "修改堆叠雪球的最大高度"),
        hover = en_zh("Increases the maximum number of snowballs you can stack (beyond vanilla limit)", "堆叠雪球无论大小，都将被限制同一高度"),
        options = get_numer_options(6, 31, 1),
        default = 31,
    },
    {
        name = "MaxSnowmanSize",
        label = en_zh("Larger snowman size", "更大雪球尺寸"),
        hover = en_zh("The super giant invincible snowball!", "超级巨型无敌大雪球！"),
        options = get_numer_options(3, 5, 1),
        default = 5,
    },
    {
        name = "MoreFunSnowball",
        label = en_zh("More fun snowball", "更好玩的滚雪球"),
        hover = en_zh("Can turn corners when rrolling snowball, and can collide other (Code source: WIGFRID)", "滚雪球时可以拐弯，并且可以撞击他人 (此功能代码来源于WIGFRI)"),
        options = boolean_options,
        default = true,
    },
    {
        name = "PUSHING_SNOWBALL_MAX_SPEED",
        label = en_zh("pushing snowball max speed", "推雪球最大速度"),
        hover = en_zh("The snowball has no brakes!", "雪球没有刹车！"),
        options = {
            {description = 10, data = 10},
            {description = 20, data = 20},
            {description = 9999, data = 9999},
        },
        default = 10,
    },
    {
        name = "SNOWBALL_DESTROY_STRUCTURE",
        label = en_zh("snowball can destroy structure", "推雪球可以摧毁建筑"),
        hover = en_zh("snowball can destroy structure", "推雪球可以摧毁建筑"),
        options = boolean_options,
        default = true,
    },
}
