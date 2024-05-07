
function WaitForScan()
    sleep(Scanner.getCooldown("portableUniversalScan") / 1000)
end

function GetPlayer()
    WaitForScan()
    players = Scanner.scan("player", 1)
    while players == nil do
        print("players was nil")
        WaitForScan()
        players = Scanner.scan("player", 2)
    end
    for index, value in ipairs(players) do
        return value
    end
    return nil
end

function GetTargetBlocks()
    WaitForScan()
    scanResult = Scanner.scan("block", tonumber(Range))
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

function TranslateToTerminal(width, height, block)
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

function Scan()
    --local player = GetPlayer()
    --if player == nil then
    --    return
    --end
    
    local blocks = GetTargetBlocks()
    if blocks == nil then
        return
    end

    term.setBackgroundColor(colors.black)
    term.clear()

    w, h = term.getSize()
    local half = math.floor(w / 2)

    for index, block in ipairs(blocks) do
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

Scanner = peripheral.find("universal_scanner")
BlockId, Range = ...

-- shoudl scan = yRot <= 135

function Main()
    BlockId = "minecraft:" .. BlockId

    while true do
        Scan()
    end
end

Main()
