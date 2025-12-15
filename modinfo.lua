
local function en_zh(en, zh)  -- Other languages don't work
    return (locale == "zh" or locale == "zhr" or locale == "zht" or locale == "ch" or locale == "chs") and zh or en
end

-- This information tells other players more about the mod
version = "1.0.0" -- mod版本 上传mod需要两次的版本不一样
name = en_zh("Ultra Deluxe Snowball Overhaul", "超级豪华魔改版雪球")  ---mod名字
description = en_zh("V".. version ..
 "\n󰀔This mod completely revamps winter snowballs! \n󰀒Now you can decorate them with various in-game items, change their skins, and create your own unique snowball art. \n󰀐Build towering snowball structures or launch them at friends for chaotic fun—winter just got a lot more exciting!",
 "V" ..version.. "\n󰀔这个MOD对冬季的雪球进行了全面升级！\n󰀒现在，你可以用游戏中的各种物品自由装饰雪球，还能更换不同的皮肤，打造独一无二的雪球艺术。\n󰀐无论是堆叠成高塔，还是用来撞击朋友，都能让你的冬季冒险更加有趣！"
)  --mod描述
author = en_zh("Guto、jerry457","Guto、jerry457") --作者

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
}

local boolean_options = {
    {description = "开启", data = true},
    {description = "关闭", data = false}
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
        label = en_zh("Modify the maximum number of snowman decorations", "修改雪人装饰的最大数量"),
        hover = en_zh("Modify the maximum number of snowman decorations", "修改雪人装饰的最大数量"),
        options = boolean_options,
        default = true,
    },
    {
        name = "WaxedSnowmanCanStack",
        label = en_zh("Waxed snowman can be stacked and decorated", "可以装饰、堆叠被打蜡的雪人"),
        hover = en_zh("Waxed snowman can be stacked and decorated", "可以装饰、堆叠被打蜡的雪人"),
        options = boolean_options,
        default = true,
    },
    {
        name = "SnowmanStackHeight",
        label = en_zh("Modify the maximum number of snowman stack height", "修改雪人装饰的最大堆叠高度"),
        hover = en_zh("Modify the maximum number of snowman stack height", "修改雪人装饰的最大堆叠高度"),
        options = get_numer_options(6, 31, 1),
        default = 31,
    },
    {
        name = "MoreFunSnowball",
        label = en_zh("More fun snowball", "更好玩的滚雪球"),
        hover = en_zh("Can turn corners when rrolling snowball, and can collide other", "滚雪球时可以拐弯，并且可以撞击他人"),
        options = boolean_options,
        default = true,
    },
}
