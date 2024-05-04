function Main()
    local p = peripheral.find("protectiveAutomata")
    if p == nil then
        print("Unable to find protective automata!")
        return
    end

    turtle.select(1)

    while true do
        local sword = turtle.getItemDetail(1, true)
        if sword.durability ~= nil and sword.durability <= 0.1 then
            print("Low durability!")
            break
        end


        local cd = p.getCooldown("swing")

        while cd ~= 0 do
            cd = p.getCooldown("swing")
            sleep(cd / 1000)
        end

        p.swing("entity")
    end
end

Main()