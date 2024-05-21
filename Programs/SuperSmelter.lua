

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
    
    local chestSlot = 0
    for i, count in pairs(matchingItems) do
        chestSlot = i
    end

    if chestSlot <= 0 then
        return false
    end

    local didWork = false
    for i, furnace in pairs(furnaces) do
        if matchingItems[chestSlot] == nil or matchingItems[chestSlot] <= 0 then
            table.remove(matchingItems, chestSlot)
            chestSlot = 0
            for i, count in pairs(matchingItems) do
                chestSlot = i
            end
            if chestSlot <= 0 then
                return false
            end
        end
        local pushResult = from.pushItems(peripheral.getName(furnace), chestSlot, 1, targetSlot)
        if pushResult ~= nil and pushResult > 0 then
            didWork = true
        end
    end
    return didWork
end

function Collect(outputChest, furnaces, fuelChest)
    local didWork = false
    for i, furnace in pairs(furnaces) do
        if fuelChest ~= nil then
            -- Get item in slot 3
            local furnaceItems = furnace.list()
            if furnaceItems ~= nil and furnaceItems[3] ~= nil then
                
                if string.find(furnaceItems[3].name, "coal") then
                    local pullResult = fuelChest.pullItems(peripheral.getName(furnace), 3)
                    if pullResult ~= nil and pullResult > 0 then
                        didWork = true
                    end
                else
                    local pullResult = outputChest.pullItems(peripheral.getName(furnace), 3)
                    if pullResult ~= nil and pullResult > 0 then
                        didWork = true
                    end
                end
            end
        else
            local pullResult = outputChest.pullItems(peripheral.getName(furnace), 3)
            if pullResult ~= nil and pullResult > 0 then
                didWork = true
            end
        end
    end
    return didWork
end

function Main()
    local configPath = "smelter.conf"
    local config = {}
    if fs.exists(configPath) then
        local configFile = fs.open(configPath, "r")
        local contents = configFile.readAll()
        configFile.close()

        config = textutils.unserialise(contents)
    else
        config["inputChest"] = ""
        config["outputChest"] = ""
        config["fuelChest"] = ""
        local configFile = fs.open(configPath, "w")
        configFile.write(textutils.serialise(config))
        configFile.close()
        print("Please fill out " .. configPath)
        return
    end
    
    local inputChest = peripheral.wrap(config["inputChest"])
    local outputChest = peripheral.wrap(config["outputChest"])
    local fuelChest = peripheral.wrap(config["fuelChest"])
    if inputChest == nil then
        print("Unable to locate input chest at " .. config["inputChest"])
        return
    end
    if outputChest == nil then
        print("Unable to locate output chest at " .. config["outputChest"])
        return
    end
    if fuelChest == nil then
        print("Unable to locate fuel chest at " .. config["fuelChest"])
        return
    end

    local pNames = peripheral.getNames()
    local furnaces = {}
    for i, pName in pairs(pNames) do
        -- If it's not a side peripheral
        if string.find(pName, "furnace") then
            table.insert(furnaces, peripheral.wrap(pName))
        end
    end

    while true do
        local didWork = false
        didWork = Distribute(inputChest, furnaces, nil, 1)
        didWork = didWork or Distribute(fuelChest, furnaces, nil, 2)
        didWork = didWork or Collect(outputChest, furnaces, fuelChest)
        if not didWork then
            os.sleep(1)
        end
    end
end

Main()