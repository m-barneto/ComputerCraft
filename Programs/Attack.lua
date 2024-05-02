p = peripheral.wrap("left")

while true do
    local cd = p.getCooldown("swing")

    while cd ~= 0 do
        cd = p.getCooldown("swing")
        sleep(cd / 1000)
    end

    p.swing("entity")
end