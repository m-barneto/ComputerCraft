
function check_if_fully_grown()
	local success, data = turtle.inspectDown()
	--if success then
	--	return data.state.age == 7
	--else
	--	return false
	--end
	if data.name == "minecraft:pumpkin" then
		return true
	else
		return false
	end
end


local width = 12
local height = 21

while true do
	for i=0,width do
		for ii=0, height do
			if check_if_fully_grown() then
				turtle.digDown()
				--turtle.placeDown()
			end
			turtle.forward()
		end
		turtle.turnRight()
		turtle.forward()
		turtle.turnRight()
		for ii=0, height do
			if check_if_fully_grown() then
				turtle.digDown()
				--turtle.placeDown()
			end
			turtle.forward()
		end
		turtle.turnLeft()
		turtle.forward()
		turtle.turnLeft()
	end

	turtle.turnLeft()
	for i = 0, width * 2 do
		turtle.forward()
	end
	turtle.turnRight()

	turtle.turnRight()
	turtle.turnRight()

	for i = 1, 16 do
		turtle.select(i)
		turtle.drop()
	end

	turtle.turnRight()
	turtle.turnRight()

	os.sleep(60 * 60)
end

print(check_if_fully_grown())

--turtle.digDown()
--turtle.placeDown()

Length, Width = ...

function Main()
	print("Starting layer ", i)
	print("Going to 0, 0 and y = ", -i * 3)
	GoToLocation(0, -i * 3, 0)
	DigLayer(Length, Width)
	if ShouldReturn() then
		GoToLocation(0, 0, 0)
		Depot()
		Refuel()
	end
	GoToLocation(0, -i * 3, 0)
	if i ~= depthPasses - 1 then
		Down()
		DigAround()
		Down()
		DigAround()
		Down()
		DigAround()
	end

end

Main()