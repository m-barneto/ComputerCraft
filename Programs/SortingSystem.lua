function HasValue(table, value)
    for i, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function HasKey(table, key)
    return table[key] ~= nil
end

function AddFilterLists(filter1, filter2)
    local filter = {}

    for i, item in pairs(filter1) do
        table.insert(filter, item)
    end
    for i, item in pairs(filter2) do
        if not HasValue(filter, item) then
            table.insert(filter, item)
        end
    end

    return filter
end

function GetFiltersBasedOnContents(chestId)
    local chest = peripheral.wrap(chestId)
    local filters = {}
    -- iterate over items and add them to filters
    for slot, item in pairs(chest.list()) do
        if item ~= nil then
            table.insert(filters, item.name)
        else
            print("encountered empty slot " .. slot)
        end
    end
    return filters
end

function UpdateChestFilters(chestId)
    -- get db filter
    local dbFilter = Database["chests"][chestId]["filters"]
    -- get content based filter
    local contentFilter = GetFiltersBasedOnContents(chestId)

    local filter = AddFilterLists(dbFilter, contentFilter)
    Database["chests"][chestId]["filters"] = filter
end

function GetDefaultChestEntry()
    local chest = {}
    chest["filters"] = {}

    return chest
end

function GetConfig()
    local configPath = "sorter.conf"
    local config = {}
    if fs.exists(configPath) then
        local configFile = fs.open(configPath, "r")
        local contents = configFile.readAll()
        configFile.close()

        config = textutils.unserialise(contents)
    else
        config["inputChest"] = ""
        config["overflowChest"] = ""
        local configFile = fs.open(configPath, "w")
        configFile.write(textutils.serialise(config))
        configFile.close()
        print("Please fill out " .. configPath)
        return nil
    end
    return config
end

function RescanChests()
    -- iterate dict first and make sure each peripheral/chest is found
    local connectedPeripherals = peripheral.getNames()

    for i, chestId in pairs(connectedPeripherals) do
        if HasKey(Database["chests"], chestId) then
            UpdateChestFilters(chestId)
        else
            -- Add new chest support here!
            if string.find(chestId, ":") and not string.find(chestId, "computer") and chestId ~= Config["inputChest"] and chestId ~= Config["overflowChest"] and not HasKey(Database["chests"], chestId) then
                Database["chests"][chestId] = GetDefaultChestEntry()
                UpdateChestFilters(chestId)
            end
        end
    end

    SaveDatabase()
end

function BuildRouter()
    Router = {}
    -- iterate over all chests in database
    for chestId, chestData in pairs(Database["chests"]) do
        -- iterate over the chest's filter items
        for i, item in pairs(chestData["filters"]) do
            Router[item] = chestId
        end
    end
end

function LoadDatabase()
    local database = {}
    if fs.exists(DB_PATH) then
        local dbFile = fs.open(DB_PATH, "r")
        local contents = dbFile.readAll()
        dbFile.close()

        database = textutils.unserialise(contents)
    else
        -- iterate over all chests and setup their sorting
        local chests = {}
        for i, chest in pairs(peripheral.getNames()) do
            if string.find(chest, ":") and chest ~= Config["inputChest"] and chest ~= Config["overflowChest"] and not HasKey(chests, chest) then
                print("Setting up default entry for " .. chest)
                chests[chest] = GetDefaultChestEntry()
            end
        end
        database["chests"] = chests
        local dbFile = fs.open(DB_PATH, "w")
        dbFile.write(textutils.serialise(database))
        dbFile.close()
    end
    return database
end

function SaveDatabase()
    local dbFile = fs.open(DB_PATH, "w")
    dbFile.write(textutils.serialise(Database))
    dbFile.close()
end

function GetItemDestination(item)
    if HasKey(Router, item) then
        local dest = peripheral.wrap(Router[item])
        if dest == nil then
            print("dest is actually not " .. Router[item])
            return OverflowChest
        end

        return dest
    end
    return OverflowChest
end

function HandleInputItems()
    -- iterate over items in inputchest and find their destination
    for slot, item in pairs(InputChest.list()) do
        if item ~= nil then
            local destChest = GetItemDestination(item.name)
            destChest.pullItems(Config["inputChest"], slot, item.count)
            print("Dest for " .. item.name .. " is " .. peripheral.getName(GetItemDestination(item.name)))
        else
            print("encountered empty slot " .. slot)
        end
    end
end

function Main()
    Config = GetConfig()
    if Config == nil then
        return
    end

    DB_PATH = "sorter.db"
    print("before load")
    Database = LoadDatabase()
    print("after load")
    
    InputChest = peripheral.wrap(Config["inputChest"])
    if InputChest == nil then
        print("Unable to locate input chest at " .. Config["inputChest"])
        return
    end

    OverflowChest = peripheral.wrap(Config["overflowChest"])
    if OverflowChest == nil then
        print("Unable to locate overflow chest at " .. Config["overflowChest"])
        return
    end
    
    RescanChests()
    BuildRouter()
    HandleInputItems()

    for i, chest in pairs(peripheral.getNames()) do
        if string.find(chest, ":") and chest ~= Config["inputChest"] and chest ~= Config["overflowChest"] then
            --GetChestEntryBasedOnContents(chest)
        end
    end
end

Main()