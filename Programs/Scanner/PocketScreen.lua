function SetupScreen()
    peripheral.find("modem", rednet.open)

    local clients = {}

    local function listen()
        while true do
            -- listen for messages
            local id, message = rednet.receive("scanner_server", .2)
            if message == "ping" then
                print("recieved from " .. id)
                table[id] = true
            end
        end
    end

    local function on_enter()
        print("Press enter when clients are connected.")
        repeat
            local _, key = os.pullEvent("key")
        until key == keys.enter
        print("Enter was pressed!")
    end

    parallel.waitForAny(listen, on_enter)

    local offset = 0
    for index, value in ipairs(clients) do
        -- send client a message with their offset here and use protocal scanner_client
        rednet.send(index, offset, "scanner_client")
        offset = offset + 1

        print("Client ".. index .. " acknowledged.")
    end

end

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
