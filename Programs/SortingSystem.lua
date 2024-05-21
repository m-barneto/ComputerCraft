function GetChestEntryBasedOnContents(chestId)
    print(textutils.serialise(Database["chests"][chestId]["filters"]))
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

function LoadDatabase(dbPath)
    local database = {}
    if fs.exists(dbPath) then
        local dbFile = fs.open(dbPath, "r")
        local contents = dbFile.readAll()
        dbFile.close()

        database = textutils.unserialise(contents)
    else
        -- iterate over all chests and setup their sorting
        local chests = {}
        for i, chest in pairs(peripheral.getNames()) do
            if string.find(chest, ":") and chest ~= Config["inputChest"] and chest ~= Config["overflowChest"] then
                print("Setting up default entry for " .. chest)
                chests[chest] = GetDefaultChestEntry()
            end
        end
        database["chests"] = chests
        local dbFile = fs.open(dbPath, "w")
        dbFile.write(textutils.serialise(database))
        dbFile.close()
    end
    return database
end

function SaveDatabase(dbPath)
    local dbFile = fs.open(dbPath, "w")
    dbFile.write(textutils.serialise(Database))
    dbFile.close()
end

function Main()
    Config = GetConfig()
    if Config == nil then
        return
    end

    local dbPath = "sorter.db"
    Database = LoadDatabase(dbPath)
    
    local inputChest = peripheral.wrap(Config["inputChest"])
    
    if inputChest == nil then
        print("Unable to locate input chest at " .. Config["inputChest"])
        return
    end

    for i, chest in pairs(peripheral.getNames()) do
        if string.find(chest, ":") and chest ~= Config["inputChest"] and chest ~= Config["overflowChest"] then
            GetChestEntryBasedOnContents(chest)
        end
    end

    
    for slot, item in pairs(inputChest.list()) do
        local info = inputChest.getItemDetail(slot)
        print(textutils.serialise(info))
    end
end

Main()