PocketId = 0

function WaitForScan()
    sleep(Scanner.getCooldown("portableUniversalScan") / 1000)
end

function GetTargetBlocks(targetBlock)
    WaitForScan()
    scanResult = Scanner.scan("block", 12)
    if scanResult == nil then
        return nil
    end

    local blocks = {}

    for index, value in ipairs(scanResult) do
        if value["name"] == BlockId then
            local block = {}
            block["x"] = value["x"]
            block["y"] = value["y"]
            block["z"] = value["z"]
            table.insert(blocks, block)
        end
    end

    return blocks
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