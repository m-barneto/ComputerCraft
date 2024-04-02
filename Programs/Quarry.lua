NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

-- dir 0 = N
--         +z
-- dir 1 = E
--         +x
-- dir 2 = S
--         -z
-- dir 3 = W
--         -x
function Forward()
    turtle.forward()
    if LocalPos.dir == NORTH then
        LocalPos.z = LocalPos.z + 1
    elseif LocalPos.dir == EAST then
        LocalPos.x = LocalPos.x + 1
    elseif LocalPos.dir == SOUTH then
        LocalPos.z = LocalPos.z - 1
    elseif LocalPos.dir == WEST then
        LocalPos.x = LocalPos.x - 1
    else
        print("ut oh ", LocalPos.dir, " is fucky wucky")
    end
end

function Left()
    turtle.turnLeft()
    LocalPos.dir = LocalPos.dir - 1
    LocalPos.dir = LocalPos.dir % 4
end

function Right()
    turtle.turnRight()
    LocalPos.dir = LocalPos.dir + 1
    LocalPos.dir = LocalPos.dir % 4
end

function Up()
    turtle.up()
    LocalPos.y = LocalPos.y + 1
end

function Down()
    turtle.down()
    LocalPos.y = LocalPos.y - 1
end

function FaceDirection(dir)
    while dir ~= LocalPos.dir do
        Right()
    end
end

function GoToLocation(x, y, z)
    if y > LocalPos.y then
        for i = 0, math.abs(LocalPos.y - y) - 1, 1 do
            Up()
        end
    elseif y < LocalPos.y then
        for i = 0, math.abs(LocalPos.y - y) - 1, 1 do
            Down()
        end
    end

    if z > LocalPos.z then
        FaceDirection(NORTH)
    elseif z < LocalPos.z then
        FaceDirection(SOUTH)
    end

    if z ~= LocalPos.z then
        for i = 0, math.abs(LocalPos.z - z) - 1, 1 do
            Forward()
        end
    end

    if x > LocalPos.x then
        FaceDirection(EAST)
    elseif x < LocalPos.x then
        FaceDirection(WEST)
    end

    if x ~= LocalPos.x then
        for i = 0, math.abs(LocalPos.x - x) - 1, 1 do
            Forward()
        end
    end

    FaceDirection(NORTH)
end

function DigAround()
    while turtle.dig() do end
    while turtle.digUp() do end
    while turtle.digDown() do end
end

function DigPath(dist)
    for i = 0, dist - 1, 1 do
        DigAround()
        Forward()
    end
    turtle.digUp()
    turtle.digDown()
    Dump()
end

function DigLayer(length, width)
    for w = 0, (width / 2) - 1, 1 do
        -- dig in line of length
        DigPath(length - 1)
        -- turn right
        Right()
        DigAround()
        Forward()
        Right()
        DigAround()
        DigPath(length - 1)
        -- turn left
        Left()
        DigAround()
        Forward()
        Left()
        turtle.digUp()
        turtle.digDown()
    end
    if width % 2 == 1 then
        DigPath(length - 1)
        print("doing weired stuff", length - 1)
    end
end

function ShouldReturn()
    local isLowOnFuel = turtle.getFuelLevel() < Length + Width + Depth + 200
    local emptySlots = 16
    for i = 1, 16, 1 do
        turtle.select(i)
        if turtle.getItemCount() > 0 then
            emptySlots = emptySlots - 1
        end
    end
    turtle.select(1)
    return true
    --return isLowOnFuel or emptySlots < 3
end

function Refuel()
    turtle.select(1)
    -- Turn left, suck items
    print("sucking fuel")
    Left()
    while turtle.getFuelLevel() < 5000 do
        turtle.suck(64)
        turtle.refuel(10)
    end
    Right()
end

function Depot()
    Right()
    Right()
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.drop()
    end
    Left()
    Left()
end

function SaveStoppingPoint()
    StoppedPos.x = LocalPos.x
    StoppedPos.y = LocalPos.y
    StoppedPos.z = LocalPos.z
    StoppedPos.dir = LocalPos.dir
end

function GoHome()
    GoToLocation(0, 0, 0)
end

Trash = {
    "minecraft:cobblestone",
    "minecraft:dirt",
    "minecraft:gravel",
    "minecraft:granite",
    "minecraft:gravel",
    "minecraft:gravel",
}

function TableContains(table, value)
    for i = 1, #table do
      if (table[i] == value) then
        return true
      end
    end
    return false
end

function Dump()
    -- get item in each slot
    for i = 1, 16, 1 do
        turtle.select(i)
        if turtle.getItemDetail() ~= nil then
            print(turtle.getItemDetail().name)
            if TableContains(Trash, turtle.getItemDetail().name) then
                turtle.dropDown()
            end
        end
    end
end

function PrintPos()
    print("Pos: ", LocalPos.x, ", ", LocalPos.y, ", ", LocalPos.z)
end


Length, Width, Depth = ...

-- set length/width from arguments

-- setup position and direction
--                x, y, z
-- dir 0 = N
--         +z
-- dir 1 = E
--         +x
-- dir 2 = S
--         -z
-- dir 3 = W
--         -x
StoppedPos = {x = 0, y = 0, z = 0, dir = NORTH}

LocalPos = {x = 0, y = 0, z = 0, dir = NORTH}

function Main()
    local depthPasses = math.floor(Depth / 3)
    local extraDepth = Depth % 3

    for i = 0, depthPasses - 1, 1 do
        DigLayer(Length, Width)
        GoToLocation(0, -i * 3, 0)
        if ShouldReturn() then
            PrintPos()
            SaveStoppingPoint()
            PrintPos()
            GoHome()
            PrintPos()
            Depot()
            Refuel()
            Depot()
            GoToLocation(StoppedPos.x, StoppedPos.y, StoppedPos.z)
            FaceDirection(StoppedPos.dir)
        end
        if i ~= depthPasses - 1 then
            Down()
            DigAround()
            Down()
            DigAround()
            Down()
            DigAround()
        end
    end

    if extraDepth ~= 0 then
        for i = 0, extraDepth - 1, 1 do
            Down()
            DigAround()
        end
        DigLayer(Length, Width)
    end
    GoToLocation(0, 0, 0)
end

Main()