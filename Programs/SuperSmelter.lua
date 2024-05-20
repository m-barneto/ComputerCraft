function Distribute(from, furnaces, filter, targetSlot)
    local matchingItems = {}
    local totalCount = 0

    for slot, item in pairs(from.list()) do
        if item == nil then goto continue end

        if filter == nil then
            filter = item.name
        end

        if item.name == filter then
            matchingItems[slot] = item.count
            totalCount = totalCount + item.count
        end
        
        ::continue::
    end
    
    for i, count in pairs(matchingItems) do
        print(i)
    end

    if #matchingItems <= 0 then
        return false
    end
    local moveCount = 0
    for i, furnace in pairs(furnaces) do
        if matchingItems[#matchingItems] == nil or matchingItems[#matchingItems] <= 0 then
            table.remove(matchingItems, #matchingItems)
        end
        local chestSlot = #matchingItems
        print(chestSlot)
        moveCount = moveCount + from.pushItems(peripheral.getName(furnace), chestSlot, 1, targetSlot)
        --furnace.pullItems(peripheral.getName(from), chestSlot, 1, targetSlot)
    end
    return moveCount > 0
end

function Collect(outputChest, furnaces, fuelChest)
    local movedCount = 0
    for i, furnace in pairs(furnaces) do
        if fuelChest ~= nil then
            -- Get item in slot 3
            local out = furnace.list()[3]
            if out ~= nil then
                
                if string.find(out.name, "coal") then
                    movedCount = movedCount + fuelChest.pullItems(peripheral.getName(furnace), 3)
                else
                    movedCount = movedCount + outputChest.pullItems(peripheral.getName(furnace), 3)
                end
            end
        else
            movedCount = movedCount + outputChest.pullItems(peripheral.getName(furnace), 3)
        end
    end
    return movedCount > 0
end

function Main()
    local pNames = peripheral.getNames()
    local furnaces = {}
    for i, pName in pairs(pNames) do
        -- If it's not a side peripheral
        if string.find(pName, "furnace") then
            table.insert(furnaces, peripheral.wrap(pName))
        end
    end

    local inputChest = "ironchest:iron_chest_8"
    local fuelChest = "minecraft:barrel_0"
    local outputChest = "ironchest:iron_chest_9"

    while true do
        local didWork = false
        didWork = Distribute(peripheral.wrap(inputChest), furnaces, nil, 1)
        didWork = didWork or Distribute(peripheral.wrap(fuelChest), furnaces, nil, 2)
        didWork = didWork or Collect(peripheral.wrap(outputChest), furnaces, peripheral.wrap(fuelChest))
        if not didWork then
            print("sleeping for 1")
            os.sleep(1)
        else
            print("doing work so no sleep")
        end
    end
end

Main()