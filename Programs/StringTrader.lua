function WaitForCooldown(p, action)
    local cd = p.getCooldown(action) / 1000
    if cd > 0 then
        os.sleep(cd)
    end
end

function DoRestock(p)
    print("Restocking.")
    local fuel = turtle.getFuelLevel()
    if fuel <= 1000 then
        print("Waiting to refuel.")
    end
    while fuel <= 1000 do
        os.sleep(1)
        fuel = turtle.getFuelLevel()
        print(fuel)
    end
    WaitForCooldown(p, "restock")
    return p.restock()
end

function RequestItems(toName, toSlot, fromName, itemName, count)
    -- Build a table from items in list()
    -- Keep a sum of matching items
    local sum = 0
    local items = {}
    for slot, itemstack in pairs(from.list()) do
        if itemstack ~= nil then
            if itemstack.name == itemName then
                sum = sum + itemstack.count
                items[slot] = itemstack.count
                -- check for early exit
            end
        end
    end
end

function WaitForItems(toName, toSlot, fromName, itemName, itemCount)
    while RequestItems(toName, toSlot, fromName, itemName, itemCount) <= 0 do
        os.sleep(.5)
    end
end

function GetStringTrade(p)
    local entity = p.look("entity")
    if entity == nil or entity.profession ~= "fletcher" then
        print("Unable to find fletcher.")
        return nil
    end
    local offers = entity.offers
    for i, offer in pairs(offers) do
        local firstInput = offer.inputs[1]
        if firstInput.name == "minecraft:string" then
            return i, firstInput.count
        end
    end
    return nil, nil
end

local i = 0
function HandleXp(p)
    i = i + 1
    if i >= 16 then
        -- suck xp and send to owner
        local collected = p.collectXP()
        local storedXp = p.getStoredXP()
        WaitForCooldown(p, "xpTransfer")
        local sent = p.sendXPToOwner(storedXp)
        print("Sending", sent, "xp to Mattdokn.")
        i = 0
    end
end

function WaitForStringInInput(inputChest)
    local inputChestFirstSlot = inputChest.getItemDetail(1)

    -- While no item is found in first slot
    while inputChestFirstSlot == nil do
        -- Wait a single tick and check again
        os.sleep(0.05)
        inputChestFirstSlot = inputChest.getItemDetail(1)
    end

    -- Now that there's an item, wait for the count to be above the required amount for the trade
    while inputChestFirstSlot.count < TradeCount do
        -- Wait a single tick and check count again
        os.sleep(.05)
        inputChestFirstSlot = inputChest.getItemDetail(1)
    end
end

function Main()
    local inputChestName = "minecraft:chest_27"
    local inputChest = peripheral.wrap(inputChestName)
    local outputChestName = "ironchest:gold_chest_15"
    local outputChest = peripheral.wrap(outputChestName)
    local turtleInventory = peripheral.wrap("bottom").getNameLocal()

    local p = peripheral.find("mercantileAutomata")
    if p == nil then
        print("Unable to find automata.")
        return
    end

    TradeIndex, TradeCount = GetStringTrade(p)
    if TradeIndex == nil then
        DoRestock(p)
        TradeIndex, TradeCount = GetStringTrade(p)
        if TradeIndex == nil then
            print("Unable to find string trade.")
            return
        end
    end

    -- commence trading
    while true do
        -- Check for trade and wait on restock cd if needed
        TradeIndex, TradeCount = GetStringTrade(p)
        if TradeIndex == nil then
            local res, val = DoRestock(p)
            TradeIndex, TradeCount = GetStringTrade(p)
            if TradeIndex == nil then
                print("Unable to find string trade.")
                return
            end
        end
        
        HandleXp(p)

        -- Wait for input chest to have enough items in first slot for full trade
        --WaitForStringInInput(inputChest)


        -- Push string from chest into turtle slot 1
        --inputChest.pushItems(turtleInventory, 1, TradeCount, 1)
        WaitForItems(turtleInventory, 1, inputChestName, "minecraft:string", TradeCount)

        -- Wait for trade to be off cooldown
        WaitForCooldown(p, "trade")
        -- Trade our string
        local amount, res = p.trade(TradeIndex)
        -- this aint right
        if amount == nil then
            print("smth aint right")
            print(res)
            inputChest.pullItems(turtleInventory, 1, 64)
        end

        -- Push items to output chest
        outputChest.pullItems(turtleInventory, 1, 64)
    end
end

Main()