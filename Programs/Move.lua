local p = peripheral.wrap("left")

local captured = p.getCaptured()

if next(captured) == nil then
    
    local cd = p.getCooldown("capture")

    while cd ~= 0 do
        print("Capture on cooldown for " .. cd / 1000 .. " seconds")
        cd = p.getCooldown("capture")
        sleep(.5)
    end

    local success, res = p.capture("block")
    if success then
        print("Success!")
    else
        print("Failed!")
        print(res)
    end
else
    local success, res = p.release()
    if success then
        print("Success!")
    else
        print("Failed!")
        print(res)
    end
end