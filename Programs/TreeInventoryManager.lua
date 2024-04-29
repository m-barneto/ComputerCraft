

Dump = "minecraft:chest_6"
Saplings = "ironchest:copper_chest_0"
Depot = "ironchest:iron_chest_0"

function MoveStack(source, dest, slot)
    local d = peripheral.wrap(dest)
    local res = d.pullItems(source, slot)
    print(res)
end

function Run()
    -- get items from dump and sort saplings to sapling chest, and sticks into who the fuck knows where idk man
    local dumpItems = peripheral.wrap(Dump).list()
    for k, v in pairs(dumpItems) do
        -- Get item details/name
        local name = v.name
        print("Slot ", k, ", ", name)
        -- if name contains sapling, then move it to saplings chest
        if string.find(name, "sapling") then
            print("Found saplings, moving them")
            MoveStack(Dump, Saplings, k)
        end
    end
end

function Main()
    while true do
        Run()
        os.sleep(10)
    end
end

Main()