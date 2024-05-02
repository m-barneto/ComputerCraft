Action = ...

if Action == nil then
    Action = "block"
end

P = peripheral.find("endAutomata")
if P == nil then
    print("Unable to find end automata!")
    shell.exit()
end

local captured = P.getCaptured()

if next(captured) == nil then
    
    local cd = P.getCooldown("capture")

    while cd ~= 0 do
        print("Capture on cooldown for " .. cd / 1000 .. " seconds")
        cd = P.getCooldown("capture")
        sleep(.5)
    end

    local success, res = P.capture(Action)
    if success then
        print("Success!")
    else
        print("Failed!")
        print(res)
    end
else
    local success, res = P.release()
    if success then
        print("Success!")
    else
        print("Failed!")
        print(res)
    end
end