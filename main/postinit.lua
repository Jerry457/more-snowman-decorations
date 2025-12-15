local files = {
    "postinit/components/snowmandecoratable.lua",
    "postinit/prefabs/snowball_item.lua",
    "postinit/prefabs/snowman.lua",
    "postinit/screens/redux/snowmandecoratingscreen.lua"
}

for _, file in ipairs(files) do
    modimport(file)
end
