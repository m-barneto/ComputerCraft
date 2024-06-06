function IsStorage(chestId)
    return string.find(chestId, ":") and chestId ~= OutputChestName and not string.find(chestId, "computer") and not string.find(chestId, "turtle")
end


OutputChestName = ...


function Main()
    local outputChest = peripheral.wrap(OutputChestName)
    if outputChest == nil then
        print("Unable to find output chest", OutputChestName)
        return
    end

    local inputInventories = {}
    local connectedPeripherals = peripheral.getNames()
    for i, chestId in pairs(connectedPeripherals) do
        -- Add new chest support here!
        if IsStorage(chestId) then
            table.insert(inputInventories, peripheral.wrap(chestId))
        end
    end

    while true do
        local totalMoved = 0
        for i, chest in pairs(inputInventories) do
            for slot, item in pairs(chest.list()) do
                totalMoved = totalMoved + chest.pushItems(OutputChestName, slot)
            end
        end
        print("Moved", totalMoved, "items.")
        os.sleep(.1)
    end
end

Main()