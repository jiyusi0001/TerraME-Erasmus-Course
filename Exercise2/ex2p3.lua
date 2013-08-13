albedo = Cell{
	white_daisy = 0.75,
	black_daisy = 0.25,
	open_land = 0.50,
	luminosity = 1
}

landcover = Cell{
	white_daisy = 0.40,
	black_daisy = 0.27,
	open_land = 0.33
}

o = Observer{
    subject = landcover,
    type = "logfile",
    attributes = {"white_daisy","black_daisy","open_land"},
    separator = ",",
    file = "/Users/tbuckley/Documents/Modeling/daisyworld.csv",
}


function get_world_albedo(landcover,albedo)
	return albedo.white_daisy * landcover.white_daisy +
	albedo.black_daisy * landcover.black_daisy +
	albedo.open_land * landcover.open_land
end

--from facilitator script that came with exercise
function get_world_temp(world_albedo,luminosity)
	absorbed_luminosity = 1-world_albedo*luminosity
	print(absorbed_luminosity)
	return 200 * absorbed_luminosity - 80
end

function get_black_daisy_temp(world_temp,world_albedo)
	return world_temp+20*(world_albedo-albedo.black_daisy)
end

function get_white_daisy_temp(world_temp,world_albedo)
	return world_temp-20*(albedo.white_daisy-world_albedo)
end

--from facilitator script that came with exercise
function get_growth(temperature)
	if temperature < 5 then
		return 0
	elseif temperature < 22.5 then
		return 0.0571 * temperature - 0.2857
	elseif temperature < 40 then
		return -0.0571 * temperature + 2.284
	else
		return 0
	end
end

t = Timer{
Event {time = 1, period = 1, action = function()
	
	world_albedo = get_world_albedo(landcover,albedo)
	print(world_albedo)
	
	world_temp = get_world_temp(world_albedo,albedo.luminosity)
	print(world_temp)

	black_daisy_temp = get_black_daisy_temp(world_temp,world_albedo)
	print(black_daisy_temp)

	white_daisy_temp = get_white_daisy_temp(world_temp,world_albedo)
	print(white_daisy_temp)

	black_daisy_growth_rate = landcover.open_land*get_growth(black_daisy_temp)
	print(black_daisy_growth_rate)

	white_daisy_growth_rate = landcover.open_land*get_growth(white_daisy_temp)
	print(white_daisy_growth_rate)

	landcover.white_daisy = landcover.white_daisy * (1+white_daisy_growth_rate) -
	landcover.white_daisy * (0.30)

	landcover.black_daisy = landcover.black_daisy * (1+black_daisy_growth_rate) -
	landcover.black_daisy * (0.30)

	landcover.open_land = 1 - landcover.black_daisy - landcover.white_daisy

	end},
	Event {time = 10, period = 9e99, action = function(e)
    	albedo.luminosity = 0.95
    end},
	Event {time = 0, period = 1, action = function(e)
    	landcover:notify(e:getTime())
    end},
}

t:execute(18)

