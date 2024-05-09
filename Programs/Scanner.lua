--[[
Clients are equipped with scanners and listen to the scanner_client protocol
Server is the screen and listens to the scanner_server protocol
]]--
TargetBlock = ...

function SetupScreen()
    peripheral.find("modem", rednet.open)

    local clients = {}
    local numClients = 0

    local start = os.epoch("utc")

    print("Starting listening.")

    while true do
        -- listen for messages
        local id, message = rednet.receive("scanner_server", .2)
        if message == "ping" then
            if clients[id] == nil then
                numClients = numClients + 1
                clients[id] = true
            end
        end
        if os.epoch("utc") >= (start + 1000) then
            break
        end
    end

    print("Found " .. numClients .. " scanner clients!")

    local data = {}
    data["targetBlock"] = "minecraft:" .. TargetBlock
    
    local offset = 0
    for index, value in pairs(clients) do
        print(index)
        -- send client a message with their offset here and use protocal scanner_client
        data["offset"] = offset / numClients
        rednet.send(index, textutils.serialise(data), "scanner_client")
        offset = offset + 1
        print("Client ".. index .. " acknowledged.")
    end
end

function ScreenLoop()
    local function TranslateToTerminal(width, height, block)
        -- 1 <-> width
        -- 1 <-> height
    
        local half = math.floor(width / 2)
    
        -- translate x,z from 0 - range to 0 - 1 and mult to fit half terminal width
        --local scaledX = math.floor(block["x"] / Range * half)
        --local scaledY = math.floor(block["z"] / Range * half)
    
        -- add to center
        local x = half - block["x"]
        local y = half + block["z"]
        return x, y
    end
    local function RenderScreen(blocks)
        local w, h = term.getSize()
        term.setBackgroundColor(colors.black)
        term.clear()
    
        local half = math.floor(w / 2)
    
        for index, block in pairs(blocks) do
            local x, y = TranslateToTerminal(w, h, block)
            local color = colors.purple
            if tonumber(block["y"]) > 0 then
                color = colors.red
            elseif tonumber(block["y"]) < 0 then
                color = colors.blue
            end
            paintutils.drawPixel(y, x, color)
        end
        
        paintutils.drawPixel(half, half, colors.blue)
    end

    while true do
        local id, data = rednet.receive("scanner_server")
        if id then
            local blocks = textutils.unserialise(data)
            RenderScreen(blocks)
        end
    end
end



function SetupScanner()
    print("Pinging scanner server.")
    peripheral.find("modem", rednet.open)
    -- send ping to server
    while true do
        rednet.broadcast("ping", "scanner_server")
        local id, msg = rednet.receive("scanner_client", .2)
        if id then
            -- message recieved, exit and process msg which should be this pcs offset
            local data = textutils.unserialize(msg)
            Offset = tonumber(data["offset"])
            TargetBlock = data["targetBlock"]
            break
        end
    end
end

function ScannerLoop()
    local scanner = peripheral.find("universal_scanner")

    local function GetTargetBlocks()
        local cd = scanner.getCooldown("portableUniversalScan") / 1000
        if cd > 0 then
            sleep(cd / 1000)
        end

        local scanResult = scanner.scan("block", 12)
        if scanResult == nil then
            return nil
        end
    
        local blocks = {}
    
        for index, value in ipairs(scanResult) do
            if value["name"] == TargetBlock then
                local block = {}
                block["x"] = value["x"]
                block["y"] = value["y"]
                block["z"] = value["z"]
                table.insert(blocks, block)
            end
        end
    
        return blocks
    end

    while true do
        -- Align ourselves to the next second + offset
        sleep(((os.epoch("utc") % 1000) / 1000) + Offset)
        local blocks = GetTargetBlocks()
        if blocks ~= nil then
            -- send blocks
            rednet.broadcast(textutils.serialize(blocks), "scanner_server")
        end
    end
end

function Main()
    if os.getComputerLabel() == "Scanner Screen" then
        SetupScreen()
        ScreenLoop()
    else
        SetupScanner()
        ScannerLoop()
    end
end

Main()