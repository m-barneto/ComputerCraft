function ConfiguratorMain()
    while true do
        -- inspect in front
        local success, data = turtle.inspect()
        if success then
            -- if inspected block is a turtle or computer            
            if data.tags["computercraft:turtle"] ~= nil or data.tags["computercraft:computer"] ~= nil then
                -- we are a turtle or computer, wrap it
                local p = peripheral.wrap("front")
                if p.isOn() ~= true then
                    p.turnOn()
                end
            end
        end
        os.sleep(.5)
    end
end

function Main()
    if os.getComputerLabel() == "Configurator" then
        print("Configurating...")
        ConfiguratorMain()
        return
    end
    shell.run("wget https://raw.githubusercontent.com/SquidDev-CC/mbs/master/mbs.lua")
    shell.run("mbs.lua install")
    print("Ready!")
end

Main()