function Main()
    local p = peripheral.find("soul_scrapper")
    if p == nil then
        print("Unable to find soul scrapper!")
        return
    end
    
    while true do
        p.harvestSoul()
    end
end

