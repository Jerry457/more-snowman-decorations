
local function en_zh(en, zh)  -- Other languages don't work
    return (locale == "zh" or locale == "zhr" or locale == "zht" or locale == "ch" or locale == "chs") and zh or en
end

-- This information tells other players more about the mod
version = "1.0.0" -- mod版本 上传mod需要两次的版本不一样
name = en_zh("More snowman decorations", "更多雪人装饰物")  ---mod名字
description = en_zh("V".. version .. 
 "\n󰀏This MOD adds more decorations to the snowman, and new items will continue to be added in the future.\n󰀌And consider increasing the flexibility of the decorations.\n󰀅Stay tuned.",
 "V" ..version.. "\n󰀏这个MOD为雪人添加了更多装饰物，并且后续仍会继续添加新物品。\n󰀌并且考虑增加装饰物的灵活度，敬请期待。"
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

configuration_options = {} --mod设置
