
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

function GetClosestTargetBlock()
    WaitForScan()
    blocks = Scanner.scan("block", Range)
    if blocks == nil then
        return nil
    end

    for index, value in ipairs(blocks) do
        if value["name"] == BlockId then
            return value
        end
    end
end

function GetCardinal(angle)
    -- angle is -180 - 180
    angle = angle + 180
    -- angle is 0 - 360
    angle = tonumber(string.format("%.f", (angle / 90))) % 4
    
    return tonumber(string.format("%.f", angle))
end

function GetDirection(x, y, z)
    return math.deg(math.atan2(x, z))
end

function GetAngleToBlock(player, block)
    --local blockAngle = GetDirection(block["x"], 0, block["z"])
    --local blockCardinal = GetCardinal(blockAngle)

    --local angle = player["yRot"]

    --local finalAngle = (blockAngle + 90) + (blockCardinal * 90) - (angle + 90)
    --return finalAngle

    


end

function Scan()
    local player = GetPlayer()
    if player == nil then
        return
    end
    
    local block = GetClosestTargetBlock()
    if block == nil then
        return
    end

    --local angle = GetAngleToBlock(player, block) + 180


    term.setBackgroundColor(colors.black)
    term.clear()

    w, h = term.getSize()
    cx = math.floor(w / 2)
    cy = math.floor(h / 2)

    --local dirX = math.cos(math.rad(angle)) * (h / 2 - 1)
    --local dirY = math.sin(math.rad(angle)) * (h / 2 - 1)

    --paintutils.drawLine(cx, cy, cx + dirX, cy + dirY, colors.white)

    paintutils.drawPixel(cx, cy, colors.blue)
    paintutils.drawPixel(0, 0, colors.red)

    paintutils.drawPixel(cx + block["z"], cy - block["x"], colors.green)
    local angle = GetDirection(block["x"], 0, block["z"])
    term.setCursorPos(1, 1)
    term.write(angle)
    term.setCursorPos(1, 2)
    term.write(90 - (player["yRot"] % 90))
    term.setCursorPos(1, 3)
    term.write(angle + ((player["yRot"] % 90) - 90))

    local adjAngleRad = math.rad(angle + ((player["yRot"] % 90) - 90) + 90)

    local xDir = math.cos(adjAngleRad) * 5
    local yDir = math.sin(adjAngleRad) * 5

    paintutils.drawLine(cx, cy, cx + xDir, cy - yDir)

    -- 97 - 90 - 89
    --    7    -1
    --   90 - 
end

Scanner = peripheral.find("universal_scanner")
BlockId = "bedrock"
Range = 8

-- shoudl scan = yRot <= 135

function Main()
    BlockId = "minecraft:" .. BlockId

    while true do
        Scan()
    end
end

Main()