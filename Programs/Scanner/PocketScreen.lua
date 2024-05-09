function Main()
    -- Listens for block data over rednet
    peripheral.find("modem", rednet.open)

    --send out setup packet
    rednet.broadcast("minecraft:bedrock", "scanner")

    while true do
        local id, message = rednet.receive("scanner")
        print(id .. ": " .. os.epoch("utc") % 10000)
        print(textutils.unserialize(message))
    end
end

Main()
