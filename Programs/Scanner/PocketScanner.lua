PocketId = 0

function WaitForScan()
    sleep(Scanner.getCooldown("portableUniversalScan") / 1000)
end

function GetTargetBlocks(targetBlock)
    WaitForScan()
    local scanResult = Scanner.scan("block", 12)
    if scanResult == nil then
        return nil
    end

    local blocks = {}

    for index, value in ipairs(scanResult) do
        if value["name"] == targetBlock then
            local block = {}
            block["x"] = value["x"]
            block["y"] = value["y"]
            block["z"] = value["z"]
            table.insert(blocks, block)
        end
    end

    return blocks
end

function SetupScanner()
    peripheral.find("modem", rednet.open)
    -- send ping to server
    while true do
        rednet.broadcast("ping", "scanner_server")
        local id, msg = rednet.receive("scanner_client", .2)
        if id then
            -- message recieved, exit and process msg which should be this pcs offset
            print("Ack! " .. msg)
            break
        end
    end
end


Scanner = peripheral.find("universal_scanner")
print(Scanner)

function Main()

    print("Scanning")
    local scanner = peripheral.wrap("universal_scanner_1")

    peripheral.find("modem", rednet.open)

    local id, message = rednet.receive("scanner")

    local targetBlock = message

    while true do
        -- Align ourselves to the next second
        -- replace pocketid * .1 with actual offset, *.1 thing was stupid
        sleep(((os.epoch("utc") % 1000) / 1000) + (PocketId * .1))
        local blocks = GetTargetBlocks(targetBlock)
        if blocks ~= nil then
            -- send blocks
            rednet.broadcast(textutils.serialize(blocks), "scanner")
            term.write(".")
        end
    end

    rednet.broadcast("Helloooooo", "scanner")
end

Main()