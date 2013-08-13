
FOREST = 1
BURNING = 2
BURNED = 3
EMPTY = 4

world = CellularSpace{
	xdim = 100,
	ydim = 100
}

world:createNeighborhood{
	strategy = "vonneumann",
	self = false
}

legend = Legend {
	grouping = "uniquevalue",
	colorBar = {
		{value = FOREST, color = "green"},
		{value = BURNING, color = "red"},
		{value = BURNED, color = "brown"},
		{value = EMPTY, color = "white"}
	}
}

mycounter = Cell{
	value = 0
}


update = function(cs)
	forEachCell(cs, function(cell)
		if cell.past.cover == FOREST then
			forEachNeighbor(cell, function(cell, neighbor)
				if neighbor.past.cover == BURNING then
					cell.cover = BURNING
				end
			end)
		elseif cell.past.cover == BURNING then
			cell.cover = BURNED
		end
	end)
end

percentages = {0.40}

for i, percent in ipairs(percentages) do
	
	forEachCell(world, function(cell)
		if math.random() > percent then
			cell.cover = FOREST
		else
			cell.cover = EMPTY
		end
	end)


	Observer{
		subject = world,
		attributes = {"cover"},
		legends = {legend}
	}

	world:sample().cover = BURNING
	world:notify()

	t = Timer{
		Event{time = 0, period = 1, action = function(e)
			world:synchronize()
			update(world)
			world:notify()
			ts = world:split("cover")
			local file = io.open("P4result.txt", "a")
			if ts[FOREST] ~= nil then
				forest = ts[FOREST]:size() 
			else
			forest = "nil"
			end

			if ts[BURNING] ~= nil then
			burning = ts[BURNING]:size() 
			else
			burning = "nil"
			end

			if ts[BURNED] ~= nil then
			burned = ts[BURNED]:size() 
			else
			burned = "nil"
			end
			
			if burning == "nil" and mycounter.value == 0 then
				writeout = file:write(percent .. "," .. e:getTime() .. "," .. forest .. "," .. burned .. "," .. burning .. "\n") or print("done")
				mycounter.value = 1
			else
			end
		end}
	}

	t:execute(400)
	mycounter.value = 0
	
end
