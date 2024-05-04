Action = ...

function Main()
    if Action == nil then
        Action = "block"
    end


    
    local p = peripheral.find("endAutomata")
    if Action == "entity" then
        p = peripheral.find("protectiveAutomata")
    end

    if p == nil then
        print("Unable to find automata!")
        return
    end
    
    local captured = p.getCaptured()
    
    if next(captured) == nil then
        
        local cd = p.getCooldown("capture")
    
        while cd ~= 0 do
            print("Capture on cooldown for " .. cd / 1000 .. " seconds")
            cd = p.getCooldown("capture")
            sleep(.5)
        end
    
        local success, res = p.capture(Action)
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
end

Main()