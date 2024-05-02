
function ChopUp()
    turtle.dig()
    turtle.digUp()
    turtle.up()
end

function ChopDown()
    turtle.dig()
    turtle.digDown()
    turtle.down()
end

function Forward()
    turtle.dig()
    turtle.forward()
end

function ChopTree()
    local treeHeight = 0
    -- mine forwards and go into hole
    Forward()
    -- ^#
    -- -#
    -- mine forward and up 30 blocks
    while turtle.detectUp()  do
        treeHeight = treeHeight + 1
        ChopUp()
    end
    turtle.dig()

    -- turn right and go in, then turn left
    -- #^
    -- #-
    turtle.turnRight()
    Forward()
    turtle.turnLeft()
    for i = 1, treeHeight, 1 do
        ChopDown()
    end
    turtle.dig()

    

    turtle.back()
    turtle.turnLeft()
    turtle.forward()
    turtle.turnRight()
    -- get saplings from chest to left here and select slot
    turtle.forward()
    turtle.place()
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
    turtle.place()
    turtle.back()
    turtle.place()
    turtle.turnLeft()
    turtle.forward()
    turtle.turnRight()
    turtle.place()
end

function PullItem(targetSlot)
    -- Assumes already facing target chest
    turtle.select(targetSlot)
    local count = turtle.getItemCount()
    while turtle.getItemCount() < 64 do
        turtle.suck(1)
        if turtle.getItemCount() ~= count + 1 then
            break
        end
        count = count + 1
    end
end

function Refuel()
    print("Getting fuel...")
    turtle.select(2)
    while turtle.getFuelLevel() < 1000 and turtle.getItemCount() > 1 do
        turtle.refuel(1)
        print(turtle.getFuelLevel())
    end
end

function Restock()
    turtle.select(1)
    -- Turn left, suck items
    turtle.turnLeft()
    -- suck bonemeal
    --print("Getting bonemeal...")
    --while turtle.getItemCount(1) < 64 do
    --    PullItem(1)
    --end
    -- suck saplings
    print("Getting saplings...")
    while turtle.getItemCount(2) < 32 do
        PullItem(1)
    end
    turtle.turnRight()
end

function Depot()
    for i = 3, 16, 1 do
        turtle.select(i)
        turtle.dropDown()
    end
    turtle.select(1)
end

function Main()
    -- check for log in front
    while true do
        local has_block, data = turtle.inspect()
        if has_block and string.find(data.name, "log") then
            ChopTree()
            print("Restocking")
            Restock()
            print("Refueling")
            Refuel()
            print("Depoting")
            Depot()
            os.sleep(60)
        else
            os.sleep(5)
        end
    end
end

Main()