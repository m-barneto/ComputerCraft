function Main()
    local p = peripheral.wrap("back")
    print("start")
    for i = 1, 41, 1 do
        local upgrade = p.isUpgrade(i)
    end
    print("ebnd")
end

Main()
