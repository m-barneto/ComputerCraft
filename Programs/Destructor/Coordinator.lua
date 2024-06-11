OutputChestName = ...

function Main()
    local outputChest = peripheral.wrap(OutputChestName)
    if outputChest == nil then
        print("Unable to find output chest", OutputChestName)
        return
    end

    -- Get a list of all connected barrels
    local barrels = {}

    local connectedPeripherals = peripheral.getNames()

    for i, peripheralId in pairs(connectedPeripherals) do
        if string.find(peripheralId, "barrel") then
            table.insert(barrels, peripheral.wrap(peripheralId))
        end
    end

    while true do
        -- Send redstone pulse and sleep until we're ready to collect items
        redstone.setOutput("bottom", true)
        os.sleep(.1)
        redstone.setOutput("bottom", false)

        -- Pulse sent, wait for destructors to work
        os.sleep(60)

        -- Collect items from barrels
        for i, barrel in pairs(barrels) do
            for slot, item in pairs(barrel.list()) do
                barrel.pushItems(OutputChestName, slot)
            end
        end
        -- Destructors are back, send them out again
    end

end

Main()