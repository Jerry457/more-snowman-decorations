local files = {
    "postinit/components/snowmandecoratable.lua",
    "postinit/prefabs/snowball_item.lua",
    "postinit/prefabs/snowman.lua",
    "postinit/screens/redux/snowmandecoratingscreen.lua",
    "postinit/components/pushable.lua",
    "postinit/prefabs/player.lua",
    "postinit/stategraph/wilson.lua",
    "postinit/widgets/hoverer.lua",
    "postinit/input.lua"
}

for _, file in ipairs(files) do
    modimport(file)
end
