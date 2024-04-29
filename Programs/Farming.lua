--region Navigation
NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

StoppedPos = {x = 0, y = 0, z = 0, dir = NORTH}
LocalPos = {x = 0, y = 0, z = 0, dir = NORTH}

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

function SaveStoppingPoint()
    StoppedPos.x = LocalPos.x
    StoppedPos.y = LocalPos.y
    StoppedPos.z = LocalPos.z
    StoppedPos.dir = LocalPos.dir
end

function PrintPos()
    print("Pos: ", LocalPos.x, ", ", LocalPos.y, ", ", LocalPos.z)
end
--endregion

Automata = peripheral.wrap("left")

function FarmPath(dist)
    for i = 0, dist - 1, 1 do
        os.sleep(Automata.getCooldown("use") / 1000.0)
        Automata.use("block", "down")
        Forward()
    end
end

function FarmLayer(length, width)
    for w = 0, (width / 2) - 1, 1 do
        -- dig in line of length
        FarmPath(length)
        -- turn right
        Right()
        Forward()
        Right()
        FarmPath(length)
        -- turn left
        Left()
        Forward()
        Left()
    end
    if width % 2 == 1 then
        FarmPath(length)
    end
end

function Depot()
    for i = 16, 1, -1 do
        turtle.select(i)
        turtle.dropDown()
    end
end

Length, Width = ...

function Main()
    while true do
        Forward()
        FarmLayer(Length, Width)
        GoToLocation(0, 0, 0)
        Depot()
        sleep(3600)
    end
end

Main()