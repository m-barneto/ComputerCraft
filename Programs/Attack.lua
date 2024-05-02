P = peripheral.find("protectiveAutomata")
if P == nil then
    print("Unable to find protective automata!")
    shell.exit()
end

turtle.select(1)

while true do
    if turtle.getItemDetail(1, true).durability <= 0.1 then
        print("Low durability!")
        break
    end


    local cd = P.getCooldown("swing")

    while cd ~= 0 do
        cd = P.getCooldown("swing")
        sleep(cd / 1000)
    end

    P.swing("entity")
end