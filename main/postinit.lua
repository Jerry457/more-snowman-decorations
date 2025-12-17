local files = {
    "postinit/input.lua",
    "postinit/components/pushable.lua",
    "postinit/components/snowmandecoratable.lua",
    "postinit/prefabs/player.lua",
    "postinit/prefabs/snowball_item.lua",
    "postinit/screens/redux/snowmandecoratingscreen.lua",
    "postinit/stategraph/wilson.lua",
    "postinit/widgets/hoverer.lua"
}

for _, file in ipairs(files) do
    modimport(file)
end
